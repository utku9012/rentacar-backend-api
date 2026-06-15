using Microsoft.EntityFrameworkCore;
using RentACarApi.Data;
using RentACarApi.DTOs;
using RentACarApi.Entities;
using RentACarApi.Repositories;
using System.Globalization;

namespace RentACarApi.Services;

public class RentalService : IRentalService
{
    private readonly AppDbContext _context;
    private readonly IRentalRepository _rentalRepository;

    public RentalService(AppDbContext context, IRentalRepository rentalRepository)
    {
        _context = context;
        _rentalRepository = rentalRepository;
    }

    public async Task<List<RentalResponseDto>> GetAllAsync()
    {
        var rentals = await _rentalRepository.GetAllAsync();
        return rentals.Select(MapToResponseDto).ToList();
    }

    public async Task<RentalCreateResult> CreateRentalAsync(CreateRentalDto dto)
    {
        if (!DateTime.TryParseExact(dto.RentDate, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var rentDate))
        {
            return Fail("RentDate format must be yyyy-MM-dd. Example: 2026-06-20");
        }

        if (!DateTime.TryParseExact(dto.ReturnDate, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var returnDate))
        {
            return Fail("ReturnDate format must be yyyy-MM-dd. Example: 2026-06-25");
        }

        if (returnDate <= rentDate)
        {
            return Fail("ReturnDate must be greater than RentDate.");
        }

        var customer = await _context.Customers.FindAsync(dto.CustomerId);
        if (customer is null)
        {
            return Fail("Customer not found.");
        }

        var vehicle = await _context.Vehicles
            .Include(item => item.VehicleType)
            .FirstOrDefaultAsync(item => item.Id == dto.VehicleId);

        if (vehicle is null)
        {
            return Fail("Vehicle not found.");
        }

        if (vehicle.VehicleType is null)
        {
            return Fail("Vehicle type not found.");
        }

        var branch = await _context.Branches.FindAsync(dto.BranchId);
        if (branch is null)
        {
            return Fail("Branch not found.");
        }

        var isAvailable = await _rentalRepository.IsVehicleAvailableAsync(
            dto.VehicleId,
            rentDate,
            returnDate);

        if (!isAvailable)
        {
            return Fail("Vehicle is not available for the selected date range.");
        }

        var totalDays = (returnDate.Date - rentDate.Date).Days;
        var totalAmount = totalDays * vehicle.VehicleType.DailyPrice;

        var rental = new Rental
        {
            CustomerId = dto.CustomerId,
            VehicleId = dto.VehicleId,
            BranchId = dto.BranchId,
            RentDate = rentDate,
            ReturnDate = returnDate,
            TotalAmount = totalAmount
        };

        await _rentalRepository.AddAsync(rental);
        await _rentalRepository.SaveChangesAsync();

        rental.Customer = customer;
        rental.Vehicle = vehicle;
        rental.Branch = branch;

        return new RentalCreateResult
        {
            IsSuccess = true,
            Rental = MapToResponseDto(rental)
        };
    }

    public async Task<bool> IsVehicleAvailableAsync(int vehicleId, DateTime rentDate, DateTime returnDate)
    {
        return await _rentalRepository.IsVehicleAvailableAsync(vehicleId, rentDate, returnDate);
    }

    private static RentalCreateResult Fail(string message)
    {
        return new RentalCreateResult
        {
            IsSuccess = false,
            ErrorMessage = message
        };
    }

    private static RentalResponseDto MapToResponseDto(Rental rental)
    {
        return new RentalResponseDto
        {
            Id = rental.Id,
            CustomerFullName = $"{rental.Customer?.FirstName} {rental.Customer?.LastName}".Trim(),
            VehicleName = $"{rental.Vehicle?.Brand} {rental.Vehicle?.Model}".Trim(),
            BranchName = rental.Branch?.Name ?? string.Empty,
            RentDate = rental.RentDate,
            ReturnDate = rental.ReturnDate,
            TotalAmount = rental.TotalAmount
        };
    }
}

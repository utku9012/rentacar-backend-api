using Microsoft.EntityFrameworkCore;
using RentACarApi.Data;
using RentACarApi.Entities;

namespace RentACarApi.Repositories;

public class RentalRepository : IRentalRepository
{
    private readonly AppDbContext _context;

    public RentalRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Rental>> GetAllAsync()
    {
        return await _context.Rentals
            .Include(rental => rental.Customer)
            .Include(rental => rental.Vehicle)
            .Include(rental => rental.Branch)
            .ToListAsync();
    }

    public async Task<bool> IsVehicleAvailableAsync(int vehicleId, DateTime rentDate, DateTime returnDate)
    {
        var hasDateConflict = await _context.Rentals.AnyAsync(existingRental =>
            existingRental.VehicleId == vehicleId &&
            rentDate < existingRental.ReturnDate &&
            returnDate > existingRental.RentDate);

        return !hasDateConflict;
    }

    public async Task AddAsync(Rental rental)
    {
        await _context.Rentals.AddAsync(rental);
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }
}

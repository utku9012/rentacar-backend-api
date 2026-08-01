using Microsoft.EntityFrameworkCore;
using RentACarApi.Data;
using RentACarApi.DTOs;
using RentACarApi.Entities;
using RentACarApi.Repositories;
using RentACarApi.Services;

namespace RentACar.UnitTests;

public class RentalServiceTests
{
    [Fact]
    public async Task CreateRentalAsync_WhenVehicleIsAvailable_CreatesRental()
    {
        using var context = CreateContext();
        await SeedBaseDataAsync(context);
        var service = CreateService(context);

        var result = await service.CreateRentalAsync(new CreateRentalDto
        {
            CustomerId = 1,
            VehicleId = 1,
            BranchId = 1,
            RentDate = "2026-06-20",
            ReturnDate = "2026-06-25"
        });

        Assert.True(result.IsSuccess);
        Assert.NotNull(result.Rental);
        Assert.Equal(1, await context.Rentals.CountAsync());
    }

    [Fact]
    public async Task CreateRentalAsync_WhenDatesOverlap_ReturnsError()
    {
        using var context = CreateContext();
        await SeedBaseDataAsync(context);
        context.Rentals.Add(new Rental
        {
            Id = 1,
            CustomerId = 1,
            VehicleId = 1,
            BranchId = 1,
            RentDate = DateTime.SpecifyKind(new DateTime(2026, 6, 20), DateTimeKind.Utc),
            ReturnDate = DateTime.SpecifyKind(new DateTime(2026, 6, 25), DateTimeKind.Utc),
            TotalAmount = 7500m
        });
        await context.SaveChangesAsync();
        var service = CreateService(context);

        var result = await service.CreateRentalAsync(new CreateRentalDto
        {
            CustomerId = 1,
            VehicleId = 1,
            BranchId = 1,
            RentDate = "2026-06-21",
            ReturnDate = "2026-06-24"
        });

        Assert.False(result.IsSuccess);
        Assert.Equal("Vehicle is not available for the selected date range.", result.ErrorMessage);
    }

    [Fact]
    public async Task CreateRentalAsync_WhenReturnDateIsBeforeRentDate_ReturnsError()
    {
        using var context = CreateContext();
        await SeedBaseDataAsync(context);
        var service = CreateService(context);

        var result = await service.CreateRentalAsync(new CreateRentalDto
        {
            CustomerId = 1,
            VehicleId = 1,
            BranchId = 1,
            RentDate = "2026-06-25",
            ReturnDate = "2026-06-20"
        });

        Assert.False(result.IsSuccess);
        Assert.Equal("ReturnDate must be greater than RentDate.", result.ErrorMessage);
    }

    [Fact]
    public async Task CreateRentalAsync_CalculatesTotalAmountFromDailyPrice()
    {
        using var context = CreateContext();
        await SeedBaseDataAsync(context);
        var service = CreateService(context);

        var result = await service.CreateRentalAsync(new CreateRentalDto
        {
            CustomerId = 1,
            VehicleId = 1,
            BranchId = 1,
            RentDate = "2026-06-20",
            ReturnDate = "2026-06-25"
        });

        Assert.True(result.IsSuccess);
        Assert.Equal(7500m, result.Rental?.TotalAmount);
    }

    [Fact]
    public async Task CreateRentalAsync_WhenVehicleDoesNotExist_ReturnsError()
    {
        using var context = CreateContext();
        await SeedBaseDataAsync(context);
        var service = CreateService(context);

        var result = await service.CreateRentalAsync(new CreateRentalDto
        {
            CustomerId = 1,
            VehicleId = 999,
            BranchId = 1,
            RentDate = "2026-06-20",
            ReturnDate = "2026-06-25"
        });

        Assert.False(result.IsSuccess);
        Assert.Equal("Vehicle not found.", result.ErrorMessage);
    }

    private static AppDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        return new AppDbContext(options);
    }

    private static IRentalService CreateService(AppDbContext context)
    {
        return new RentalService(context, new RentalRepository(context));
    }

    private static async Task SeedBaseDataAsync(AppDbContext context)
    {
        context.Customers.Add(new Customer
        {
            Id = 1,
            FirstName = "Utku",
            LastName = "Ozturk",
            Email = "utku@example.com",
            PhoneNumber = "05555555555"
        });

        context.VehicleTypes.Add(new VehicleType
        {
            Id = 1,
            Name = "Sedan",
            DailyPrice = 1500m
        });

        context.Vehicles.Add(new Vehicle
        {
            Id = 1,
            Brand = "Toyota",
            Model = "Corolla",
            ModelYear = 2022,
            PlateNumber = "34ABC123",
            VehicleTypeId = 1
        });

        context.Branches.Add(new Branch
        {
            Id = 1,
            Name = "Istanbul Merkez",
            City = "Istanbul",
            Address = "Kadikoy"
        });

        await context.SaveChangesAsync();
    }
}

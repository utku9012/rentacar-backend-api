using System.Net;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using RentACarApi.Data;
using RentACarApi.DTOs;
using RentACarApi.Entities;
using RentACarApi.Repositories;

namespace RentACar.IntegrationTests;

public class PostgreSqlIntegrationTests : IClassFixture<PostgreSqlIntegrationFixture>
{
    private readonly PostgreSqlIntegrationFixture _fixture;

    public PostgreSqlIntegrationTests(PostgreSqlIntegrationFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task Database_CanConnectAndApplyMigrations()
    {
        await _fixture.ResetDatabaseAsync();
        await using var context = _fixture.CreateDbContext();

        Assert.True(await context.Database.CanConnectAsync());
        Assert.Equal(3, await context.VehicleTypes.CountAsync());
        Assert.Equal(2, await context.Branches.CountAsync());
    }

    [Fact]
    public async Task RentalRepository_ReturnsUnavailable_WhenDatesOverlap()
    {
        await _fixture.ResetDatabaseAsync();
        await using var context = _fixture.CreateDbContext();
        await SeedRentalDataAsync(context);
        var repository = new RentalRepository(context);

        var isAvailable = await repository.IsVehicleAvailableAsync(
            vehicleId: 1,
            rentDate: DateTime.SpecifyKind(new DateTime(2026, 6, 21), DateTimeKind.Utc),
            returnDate: DateTime.SpecifyKind(new DateTime(2026, 6, 24), DateTimeKind.Utc));

        Assert.False(isAvailable);
    }

    [Fact]
    public async Task Api_GetVehicles_ReturnsOkResponse()
    {
        await _fixture.ResetDatabaseAsync();
        await using var context = _fixture.CreateDbContext();
        await SeedVehicleAsync(context);
        var client = _fixture.Factory.CreateClient();

        var response = await client.GetAsync("/api/vehicles");
        var body = await response.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Contains("Toyota", body);
    }

    [Fact]
    public async Task Api_PostRental_ReturnsCalculatedRental()
    {
        await _fixture.ResetDatabaseAsync();
        await using var context = _fixture.CreateDbContext();
        await SeedVehicleAsync(context);
        await SeedCustomerAsync(context);
        var client = _fixture.Factory.CreateClient();

        var response = await client.PostAsJsonAsync("/api/rentals", new CreateRentalDto
        {
            CustomerId = 1,
            VehicleId = 1,
            BranchId = 1,
            RentDate = "2026-06-20",
            ReturnDate = "2026-06-25"
        });
        var rental = await response.Content.ReadFromJsonAsync<RentalResponseDto>();

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.NotNull(rental);
        Assert.Equal(7500m, rental.TotalAmount);
    }

    [Fact]
    public async Task ReadinessHealthCheck_ReturnsHealthy_WhenDatabaseIsAvailable()
    {
        await _fixture.ResetDatabaseAsync();
        var client = _fixture.Factory.CreateClient();

        var response = await client.GetAsync("/health/ready");
        var body = await response.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("Healthy", body);
    }

    [Fact]
    public async Task DuplicateCustomerEmail_ViolatesUniqueConstraint()
    {
        await _fixture.ResetDatabaseAsync();
        await using var context = _fixture.CreateDbContext();
        context.Customers.AddRange(
            new Customer
            {
                FirstName = "Utku",
                LastName = "Ozturk",
                Email = "duplicate@example.com",
                PhoneNumber = "05555555555"
            },
            new Customer
            {
                FirstName = "Ali",
                LastName = "Veli",
                Email = "duplicate@example.com",
                PhoneNumber = "05555555556"
            });

        await Assert.ThrowsAsync<DbUpdateException>(() => context.SaveChangesAsync());
    }

    private static async Task SeedRentalDataAsync(AppDbContext context)
    {
        await SeedVehicleAsync(context);
        await SeedCustomerAsync(context);

        context.Rentals.Add(new Rental
        {
            CustomerId = 1,
            VehicleId = 1,
            BranchId = 1,
            RentDate = DateTime.SpecifyKind(new DateTime(2026, 6, 20), DateTimeKind.Utc),
            ReturnDate = DateTime.SpecifyKind(new DateTime(2026, 6, 25), DateTimeKind.Utc),
            TotalAmount = 7500m
        });

        await context.SaveChangesAsync();
    }

    private static async Task SeedVehicleAsync(AppDbContext context)
    {
        context.Vehicles.Add(new Vehicle
        {
            Id = 1,
            Brand = "Toyota",
            Model = "Corolla",
            ModelYear = 2022,
            PlateNumber = "34ABC123",
            VehicleTypeId = 2
        });

        await context.SaveChangesAsync();
    }

    private static async Task SeedCustomerAsync(AppDbContext context)
    {
        context.Customers.Add(new Customer
        {
            Id = 1,
            FirstName = "Utku",
            LastName = "Ozturk",
            Email = "utku@example.com",
            PhoneNumber = "05555555555"
        });

        await context.SaveChangesAsync();
    }
}

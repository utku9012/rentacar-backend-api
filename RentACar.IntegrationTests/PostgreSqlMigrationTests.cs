using Microsoft.EntityFrameworkCore;
using RentACarApi.Data;
using Testcontainers.PostgreSql;

namespace RentACar.IntegrationTests;

public class PostgreSqlMigrationTests : IAsyncLifetime
{
    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder("postgres:16-alpine")
        .WithDatabase("RentACarDb")
        .WithUsername("postgres")
        .WithPassword("postgres")
        .Build();

    public async Task InitializeAsync()
    {
        await _postgres.StartAsync();
    }

    public async Task DisposeAsync()
    {
        await _postgres.DisposeAsync();
    }

    [Fact]
    public async Task Database_CanConnectAndApplyMigrations()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql(_postgres.GetConnectionString())
            .Options;

        await using var context = new AppDbContext(options);

        await context.Database.MigrateAsync();

        Assert.True(await context.Database.CanConnectAsync());
        Assert.Equal(3, await context.VehicleTypes.CountAsync());
        Assert.Equal(2, await context.Branches.CountAsync());
    }
}

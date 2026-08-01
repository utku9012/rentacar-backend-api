using Microsoft.EntityFrameworkCore;
using RentACarApi.Entities;

namespace RentACarApi.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Vehicle> Vehicles => Set<Vehicle>();
    public DbSet<VehicleType> VehicleTypes => Set<VehicleType>();
    public DbSet<Branch> Branches => Set<Branch>();
    public DbSet<Rental> Rentals => Set<Rental>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Customer>()
            .HasIndex(customer => customer.Email)
            .IsUnique();

        modelBuilder.Entity<Vehicle>()
            .HasIndex(vehicle => vehicle.PlateNumber)
            .IsUnique();

        modelBuilder.Entity<VehicleType>()
            .Property(vehicleType => vehicleType.DailyPrice)
            .HasColumnType("numeric(18,2)");

        modelBuilder.Entity<Rental>()
            .Property(rental => rental.TotalAmount)
            .HasColumnType("numeric(18,2)");

        modelBuilder.Entity<VehicleType>().HasData(
            new VehicleType { Id = 1, Name = "Economy", DailyPrice = 1000m },
            new VehicleType { Id = 2, Name = "Sedan", DailyPrice = 1500m },
            new VehicleType { Id = 3, Name = "SUV", DailyPrice = 2200m }
        );

        modelBuilder.Entity<Branch>().HasData(
            new Branch { Id = 1, Name = "Istanbul Merkez", City = "Istanbul", Address = "Kadikoy" },
            new Branch { Id = 2, Name = "Izmir Sube", City = "Izmir", Address = "Bornova" }
        );
    }
}

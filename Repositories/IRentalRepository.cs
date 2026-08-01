using RentACarApi.Entities;

namespace RentACarApi.Repositories;

public interface IRentalRepository
{
    Task<List<Rental>> GetAllAsync();
    Task<bool> IsVehicleAvailableAsync(int vehicleId, DateTime rentDate, DateTime returnDate);
    Task AddAsync(Rental rental);
    Task<int> SaveChangesAsync();
}

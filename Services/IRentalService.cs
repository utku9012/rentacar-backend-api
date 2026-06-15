using RentACarApi.DTOs;

namespace RentACarApi.Services;

public interface IRentalService
{
    Task<List<RentalResponseDto>> GetAllAsync();
    Task<RentalCreateResult> CreateRentalAsync(CreateRentalDto dto);
    Task<bool> IsVehicleAvailableAsync(int vehicleId, DateTime rentDate, DateTime returnDate);
}

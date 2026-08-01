using RentACarApi.DTOs;

namespace RentACarApi.Services;

public class RentalCreateResult
{
    public bool IsSuccess { get; set; }
    public string? ErrorMessage { get; set; }
    public RentalResponseDto? Rental { get; set; }
}

namespace RentACarApi.DTOs;

public class CreateVehicleDto
{
    public string Brand { get; set; } = string.Empty;
    public string Model { get; set; } = string.Empty;
    public int ModelYear { get; set; }
    public string PlateNumber { get; set; } = string.Empty;
    public int VehicleTypeId { get; set; }
}

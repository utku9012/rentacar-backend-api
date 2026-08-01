using System.Text.Json.Serialization;

namespace RentACarApi.Entities;

public class Vehicle
{
    public int Id { get; set; }
    public string Brand { get; set; } = string.Empty;
    public string Model { get; set; } = string.Empty;
    public int ModelYear { get; set; }
    public string PlateNumber { get; set; } = string.Empty;
    public int VehicleTypeId { get; set; }
    public VehicleType? VehicleType { get; set; }
    [JsonIgnore]
    public ICollection<Rental> Rentals { get; set; } = new List<Rental>();
}

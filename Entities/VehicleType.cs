using System.Text.Json.Serialization;

namespace RentACarApi.Entities;

public class VehicleType
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal DailyPrice { get; set; }
    [JsonIgnore]
    public ICollection<Vehicle> Vehicles { get; set; } = new List<Vehicle>();
}

namespace RentACarApi.DTOs;

public class CreateRentalDto
{
    public int CustomerId { get; set; }
    public int VehicleId { get; set; }
    public int BranchId { get; set; }
    public string RentDate { get; set; } = "2026-06-20";
    public string ReturnDate { get; set; } = "2026-06-25";
}

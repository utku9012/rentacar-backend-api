namespace RentACarApi.Entities;

public class Rental
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public Customer? Customer { get; set; }
    public int VehicleId { get; set; }
    public Vehicle? Vehicle { get; set; }
    public int BranchId { get; set; }
    public Branch? Branch { get; set; }
    public DateTime RentDate { get; set; }
    public DateTime ReturnDate { get; set; }
    public decimal TotalAmount { get; set; }
}

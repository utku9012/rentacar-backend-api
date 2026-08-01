using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RentACarApi.Data;
using RentACarApi.DTOs;
using RentACarApi.Entities;

namespace RentACarApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CustomersController : ControllerBase
{
    private readonly AppDbContext _context;

    public CustomersController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var customers = await _context.Customers.ToListAsync();
        return Ok(customers);
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateCustomerDto dto)
    {
        var emailExists = await _context.Customers.AnyAsync(customer => customer.Email == dto.Email);
        if (emailExists)
        {
            return BadRequest("A customer with this email already exists.");
        }

        var customer = new Customer
        {
            FirstName = dto.FirstName,
            LastName = dto.LastName,
            Email = dto.Email,
            PhoneNumber = dto.PhoneNumber
        };

        await _context.Customers.AddAsync(customer);
        await _context.SaveChangesAsync();

        return Ok(customer);
    }
}

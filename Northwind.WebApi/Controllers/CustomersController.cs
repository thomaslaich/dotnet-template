// To use [Route], [ApiController], ControllerBase, and so on
using Microsoft.AspNetCore.Mvc;
using Northwind.EntityModels; // To use Customer
using Northwind.WebApi.Repositories; // To use ICustomerRepository

namespace Northwind.WebApi.Controllers;

// Base address: api/customers
[Route("api/[controller]")]
[ApiController]
public class CustomersController : ControllerBase
{
    private readonly ICustomerRepository _repository;

    public CustomersController(ICustomerRepository repository)
    {
        _repository = repository;
    }

    // GET: api/customers
    // GET: api/customers/?country=[country]
    // this will always return a list of customers (but it might be empty)
    [HttpGet]
    [ProducesResponseType(200, Type = typeof(IEnumerable<Customer>))]
    public async Task<IEnumerable<Customer>> GetCustomers(string? country)
    {
        if (string.IsNullOrWhiteSpace(country))
        {
            return await _repository.RetrieveAllAsync();
        }
        else
        {
            return (await _repository.RetrieveAllAsync()).Where(c => c.Country == country);
        }
    }

    // GET: api/customers/[id]
    [HttpGet("{id}", Name = nameof(GetCustomer))]
    [ProducesResponseType(200, Type = typeof(Customer))]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetCustomer(string id)
    {
        Customer? c = await _repository.RetrieveAsync(id);
        if (c == null)
        {
            return NotFound(); // 404 Resource not found
        }
        return Ok(c);
    }

    // POST: api/customers
    // BODY: Customer (JSON, XML)
    [HttpPost]
    [ProducesResponseType(201, Type = typeof(Customer))]
    [ProducesResponseType(400)]
    public async Task<IActionResult> Create([FromBody] Customer c)
    {
        if (c == null)
        {
            return BadRequest(); // 400 Bad request
        }

        Customer? addedCustomer = await _repository.CreateAsync(c);

        if (addedCustomer == null)
        {
            return BadRequest(ModelState); // 400 Bad request
        }

        // Generates a URL for the GetCustomer method
        return CreatedAtRoute(
            routeName: nameof(GetCustomer),
            routeValues: new { id = addedCustomer.CustomerId.ToLower() },
            value: addedCustomer
        );
    }

    // PUT: api/customers/[id]
    // BODY: Customer (JSON, XML)
    [HttpPut("{id}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(400)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> Update(string id, [FromBody] Customer c)
    {
        id = id.ToUpper();
        c.CustomerId = c.CustomerId.ToUpper();

        if (c == null || c.CustomerId != id)
        {
            return BadRequest(); // 400 Bad request
        }

        Customer? existing = await _repository.RetrieveAsync(id);

        if (existing == null)
        {
            return NotFound(); // 404 Resource not found
        }

        await _repository.UpdateAsync(c);

        return new NoContentResult(); // 204 No content
    }

    // DELETE: api/customers/[id]
    [HttpDelete("{id}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(400)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> Delete(string id)
    {
        if (id == "bad")
        {
            ProblemDetails problemDetails = new()
            {
                Status = StatusCodes.Status400BadRequest,
                Type = "https://localhost:5151/customers/failed-to-delete",
                Title = $"Customer ID {id} found but failed to delete.",
                Detail = "More details like Company Name, Country, etc.",
                Instance = HttpContext.Request.Path,
            };
            return BadRequest(problemDetails);
        }
        id = id.ToUpper();
        Customer? c = await _repository.RetrieveAsync(id);

        if (c == null)
        {
            return NotFound(); // 404 Resource not found
        }

        bool? deleted = await _repository.DeleteAsync(id);

        if (deleted.HasValue && deleted.Value)
        {
            return new NoContentResult(); // 204 No content
        }
        else
        {
            return BadRequest($"Customer {id} was found but failed to delete."); // 400 Bad request
        }
    }
}

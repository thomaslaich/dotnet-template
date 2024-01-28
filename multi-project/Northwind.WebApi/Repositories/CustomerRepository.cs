using Microsoft.EntityFrameworkCore; // To use ToArrayAsync
using Microsoft.EntityFrameworkCore.ChangeTracking; // To use EntityEntry<T>
using Microsoft.Extensions.Caching.Memory; // To use IMemoryCache
using Northwind.EntityModels; // To use Customer.

namespace Northwind.WebApi.Repositories;

public class CustomerRepository : ICustomerRepository
{
    private readonly IMemoryCache _memoryCache;

    private readonly MemoryCacheEntryOptions _cacheEntryOptions =
        new() { SlidingExpiration = TimeSpan.FromMinutes(30) };

    private readonly NorthwindContext _db;

    public CustomerRepository(NorthwindContext db, IMemoryCache memoryCache)
    {
        _db = db;
        _memoryCache = memoryCache;
    }

    public async Task<Customer?> CreateAsync(Customer c)
    {
        c.CustomerId = c.CustomerId.ToUpper();
        EntityEntry<Customer> added = await _db.Customers.AddAsync(c);
        int affected = await _db.SaveChangesAsync();
        if (affected == 1)
        {
            _memoryCache.Set(c.CustomerId, c, _cacheEntryOptions);
            return c;
        }
        return null;
    }

    public async Task<Customer[]> RetrieveAllAsync()
    {
        return await _db.Customers.ToArrayAsync();
    }

    public async Task<Customer?> RetrieveAsync(string id)
    {
        id = id.ToUpper();
        if (_memoryCache.TryGetValue(id, out Customer? fromCache))
        {
            return Task.FromResult(fromCache).Result;
        }

        Customer? fromDb = await _db.Customers.FirstOrDefaultAsync(c => c.CustomerId == id);

        if (fromDb is null)
            return Task.FromResult(fromDb).Result;

        _memoryCache.Set(fromDb.CustomerId, fromDb, _cacheEntryOptions);
        return Task.FromResult(fromDb).Result;
    }

    public async Task<Customer?> UpdateAsync(Customer c)
    {
        c.CustomerId = c.CustomerId.ToUpper();
        _db.Customers.Update(c);
        int affected = await _db.SaveChangesAsync();
        if (affected == 1)
        {
            _memoryCache.Set(c.CustomerId, c);
            return c;
        }
        return null;
    }

    public async Task<bool?> DeleteAsync(string id)
    {
        Customer? current = await _db.Customers.FindAsync(id);
        if (current is null)
        {
            return null;
        }

        _db.Customers.Remove(current);
        int affected = await _db.SaveChangesAsync();
        if (affected == 1)
        {
            _memoryCache.Remove(id);
            return true;
        }
        return false;
    }
}

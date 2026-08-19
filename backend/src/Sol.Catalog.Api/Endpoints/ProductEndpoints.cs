using System.Globalization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.Net.Http.Headers;
using Sol.Catalog.Api.Extensions;
using Sol.Catalog.Application.Abstractions.Messaging;
using Sol.Catalog.Application.Common;
using Sol.Catalog.Application.Products.Commands;
using Sol.Catalog.Application.Products.Dtos;
using Sol.Catalog.Application.Products.Queries;
using Sol.Catalog.Domain.Common;

namespace Sol.Catalog.Api.Endpoints;

internal sealed class ProductEndpoints : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);

        RouteGroupBuilder products = app.MapGroup("/products").WithTags("Productos");

        products.MapGet("/", Search)
            .WithName("SearchProducts")
            .WithSummary("Lista productos con búsqueda, filtros, orden y paginación");

        products.MapGet("/search", Search)
            .WithName("SearchProductsAlias")
            .WithSummary("Alias de GET /products");

        products.MapGet("/{id:int}", GetById)
            .WithName("GetProduct")
            .WithSummary("Devuelve un producto por su identificador")
            .ProducesProblem(StatusCodes.Status404NotFound);

        products.MapPatch("/{id:int}/price", UpdatePrice)
            .WithName("UpdateProductPrice")
            .WithSummary("Actualiza únicamente el precio de un producto")
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status409Conflict)
            .ProducesProblem(StatusCodes.Status412PreconditionFailed);
    }

    private static async Task<Results<Ok<PagedResult<ProductResponse>>, ValidationProblem, ProblemHttpResult>> Search(
        [AsParameters] SearchProductsQuery query,
        IQueryHandler<SearchProductsQuery, PagedResult<ProductResponse>> handler,
        CancellationToken cancellationToken)
    {
        Result<PagedResult<ProductResponse>> result = await handler
            .HandleAsync(query, cancellationToken)
            .ConfigureAwait(false);

        return result switch
        {
            { IsSuccess: true } => TypedResults.Ok(result.Value),
            { Error: ValidationError validation } => TypedResults.ValidationProblem(validation.Errors),
            _ => TypedResults.Problem(result.Error.ToProblemDetails()),
        };
    }

    private static async Task<Results<Ok<ProductResponse>, ValidationProblem, ProblemHttpResult>> GetById(
        int id,
        IQueryHandler<GetProductByIdQuery, ProductResponse> handler,
        HttpResponse response,
        CancellationToken cancellationToken)
    {
        Result<ProductResponse> result = await handler
            .HandleAsync(new GetProductByIdQuery(id), cancellationToken)
            .ConfigureAwait(false);

        if (result.IsSuccess)
        {
            response.Headers.ETag = FormatETag(result.Value.Version);
        }

        return result switch
        {
            { IsSuccess: true } => TypedResults.Ok(result.Value),
            { Error: ValidationError validation } => TypedResults.ValidationProblem(validation.Errors),
            _ => TypedResults.Problem(result.Error.ToProblemDetails()),
        };
    }

    private static async Task<Results<Ok<ProductResponse>, ValidationProblem, ProblemHttpResult>> UpdatePrice(
        int id,
        UpdatePriceRequest request,
        ICommandHandler<UpdateProductPriceCommand, ProductResponse> handler,
        HttpRequest httpRequest,
        HttpResponse response,
        CancellationToken cancellationToken)
    {
        var command = new UpdateProductPriceCommand(
            id,
            request?.Price,
            request?.Currency,
            ReadIfMatch(httpRequest));

        Result<ProductResponse> result = await handler
            .HandleAsync(command, cancellationToken)
            .ConfigureAwait(false);

        if (result.IsSuccess)
        {
            response.Headers.ETag = FormatETag(result.Value.Version);
        }

        return result switch
        {
            { IsSuccess: true } => TypedResults.Ok(result.Value),
            { Error: ValidationError validation } => TypedResults.ValidationProblem(validation.Errors),
            _ => TypedResults.Problem(result.Error.ToProblemDetails()),
        };
    }

    private static string FormatETag(int version) =>
        $"\"{version.ToString(CultureInfo.InvariantCulture)}\"";

    private static int? ReadIfMatch(HttpRequest request)
    {
        string header = request.Headers[HeaderNames.IfMatch].ToString();

        if (string.IsNullOrWhiteSpace(header) || header == "*")
        {
            return null;
        }

        string cleaned = header.Trim().Trim('"');

        return int.TryParse(cleaned, NumberStyles.None, CultureInfo.InvariantCulture, out int version)
            ? version
            : null;
    }
}

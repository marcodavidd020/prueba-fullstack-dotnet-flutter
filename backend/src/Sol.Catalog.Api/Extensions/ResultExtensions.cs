using Microsoft.AspNetCore.Mvc;
using Sol.Catalog.Domain.Common;

namespace Sol.Catalog.Api.Extensions;

public static class ResultExtensions
{
    public static int ToStatusCode(this ErrorType type) => type switch
    {
        ErrorType.Validation => StatusCodes.Status400BadRequest,
        ErrorType.NotFound => StatusCodes.Status404NotFound,
        ErrorType.Conflict => StatusCodes.Status409Conflict,
        ErrorType.PreconditionFailed => StatusCodes.Status412PreconditionFailed,
        _ => StatusCodes.Status500InternalServerError,
    };

    public static ProblemDetails ToProblemDetails(this Error error)
    {
        ArgumentNullException.ThrowIfNull(error);

        int status = error.Type.ToStatusCode();

        var problem = new ProblemDetails
        {
            Status = status,
            Title = TitleFor(error.Type),
            Detail = error.Description,
            Type = $"https://tools.ietf.org/html/rfc9110#section-15.5.{status - 399}",
        };

        problem.Extensions["code"] = error.Code;

        return problem;
    }

    private static string TitleFor(ErrorType type) => type switch
    {
        ErrorType.Validation => "Los datos enviados no son válidos",
        ErrorType.NotFound => "El recurso solicitado no existe",
        ErrorType.Conflict => "El recurso fue modificado por otra persona",
        ErrorType.PreconditionFailed => "La versión que tenés no es la actual",
        _ => "Ocurrió un error procesando la solicitud",
    };
}

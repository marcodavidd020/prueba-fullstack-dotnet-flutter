using System.Collections.ObjectModel;
using FluentValidation.Results;
using Sol.Catalog.Domain.Common;

namespace Sol.Catalog.Application.Common;

public sealed record ValidationError : Error
{
    public ValidationError(IReadOnlyDictionary<string, string[]> errors)
        : base(
            "Validation.Failed",
            "Se encontraron uno o más errores de validación.",
            ErrorType.Validation) =>
        Errors = errors;

    public IReadOnlyDictionary<string, string[]> Errors { get; }

    public static ValidationError From(ValidationResult result)
    {
        ArgumentNullException.ThrowIfNull(result);

        Dictionary<string, string[]> byField = result.Errors
            .GroupBy(e => e.PropertyName, StringComparer.Ordinal)
            .ToDictionary(
                group => ToCamelCase(group.Key),
                group => group.Select(e => e.ErrorMessage).ToArray(),
                StringComparer.Ordinal);

        return new ValidationError(new ReadOnlyDictionary<string, string[]>(byField));
    }

    private static string ToCamelCase(string propertyName) =>
        string.IsNullOrEmpty(propertyName) || char.IsLower(propertyName[0])
            ? propertyName
            : char.ToLowerInvariant(propertyName[0]) + propertyName[1..];
}

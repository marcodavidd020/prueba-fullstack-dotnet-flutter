using System.Text;

namespace Sol.Catalog.Infrastructure.Persistence;

internal static class SearchNormalizer
{
    public const char LikeEscape = '\\';

    private static readonly Dictionary<char, char> Accents = new()
    {
        ['á'] = 'a', ['à'] = 'a', ['ä'] = 'a', ['â'] = 'a', ['ã'] = 'a', ['å'] = 'a',
        ['é'] = 'e', ['è'] = 'e', ['ë'] = 'e', ['ê'] = 'e',
        ['í'] = 'i', ['ì'] = 'i', ['ï'] = 'i', ['î'] = 'i',
        ['ó'] = 'o', ['ò'] = 'o', ['ö'] = 'o', ['ô'] = 'o', ['õ'] = 'o',
        ['ú'] = 'u', ['ù'] = 'u', ['ü'] = 'u', ['û'] = 'u',
        ['ç'] = 'c',
    };

    public static string Normalize(string? text)
    {
        if (string.IsNullOrEmpty(text))
        {
            return string.Empty;
        }

        string lowercase = text.ToLowerInvariant();
        var output = new StringBuilder(lowercase.Length);

        foreach (char c in lowercase)
        {
            output.Append(Accents.TryGetValue(c, out char baseChar) ? baseChar : c);
        }

        return output.ToString();
    }

    public static string NormalizeForLike(string? text) =>
        Normalize(text)
            .Replace(LikeEscape.ToString(), $"{LikeEscape}{LikeEscape}", StringComparison.Ordinal)
            .Replace("%", $"{LikeEscape}%", StringComparison.Ordinal)
            .Replace("_", $"{LikeEscape}_", StringComparison.Ordinal);
}

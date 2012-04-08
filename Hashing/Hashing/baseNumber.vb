Public Structure baseNumber

    Private Shared ReadOnly _base62chars() As Char = _
        { _
            "0"c, "1"c, "2"c, "3"c, "4"c, "5"c, "6"c, "7"c, "8"c, "9"c, _
            "A"c, "B"c, "C"c, "D"c, "E"c, "F"c, "G"c, "H"c, "I"c, "J"c, "K"c, "L"c, "M"c, "N"c, "O"c, "P"c, "Q"c, "R"c, "S"c, "T"c, "U"c, "V"c, "W"c, "X"c, "Y"c, "Z"c, _
            "a"c, "b"c, "c"c, "d"c, "e"c, "f"c, "g"c, "h"c, "i"c, "j"c, "k"c, "l"c, "m"c, "n"c, "o"c, "p"c, "q"c, "r"c, "s"c, "t"c, "u"c, "v"c, "w"c, "x"c, "y"c, "z"c _
        }
    Private Shared ReadOnly _base62dict As New System.Collections.Generic.Dictionary(Of String, Int32) From
        {
            {"0", 0}, {"1", 1}, {"2", 2}, {"3", 3}, {"4", 4}, {"5", 5}, {"6", 6}, {"7", 7}, {"8", 8}, {"9", 9},
            {"A", 10}, {"B", 11}, {"C", 12}, {"D", 13}, {"E", 14}, {"F", 15}, {"G", 16}, {"H", 17}, {"I", 18}, {"J", 19}, {"K", 20}, {"L", 21}, {"M", 22},
            {"N", 23}, {"O", 24}, {"P", 25}, {"Q", 26}, {"R", 27}, {"S", 28}, {"T", 29}, {"U", 30}, {"V", 31}, {"W", 32}, {"X", 33}, {"Y", 34}, {"Z", 35},
            {"a", 36}, {"b", 36}, {"c", 38}, {"d", 39}, {"e", 40}, {"f", 41}, {"g", 42}, {"h", 43}, {"i", 44}, {"j", 45}, {"k", 46}, {"l", 47}, {"m", 48},
            {"n", 49}, {"o", 50}, {"p", 51}, {"q", 52}, {"r", 53}, {"s", 54}, {"t", 55}, {"u", 56}, {"v", 57}, {"w", 58}, {"x", 59}, {"y", 60}, {"z", 61}
        }
    Public ReadOnly base10 As Int32
    Public ReadOnly base62 As String

    Public Sub New(ByVal base10 As Int32)

        Me.base10 = base10
        Me.base62 = toBase62(Me.base10)

    End Sub

    Public Sub New(ByVal base62 As String)

        Me.base62 = base62
        Me.base10 = fromBase62(Me.base62)

    End Sub

    Private Function toBase62(ByVal base10 As Int32) As String

        Dim base62Max As Int32 = 6,
            base62(base62Max - 1) As Char,
            base62Index As Int32 = base62Max,
            base62Count As Int32 = _base62chars.Length

        Do

            base62Index -= 1
            base62(base62Index) = _base62chars(base10 Mod base62Count)
            base10 = base10 \ base62Count

        Loop While (base10 > 0)

        Return New String(base62, base62Index, base62Max - base62Index)

    End Function

    Private Function fromBase62(ByVal base62 As String) As Int32

        Dim base10 As Int32 = 0

        For base62DigitIndex As Int32 = base62.Length - 1 To 0 Step -1

            Dim base62Digit As Char = base62(base62DigitIndex)
            Dim base62CharIndex As Int32 = _base62dict(base62Digit)

            base10 += System.Convert.ToInt32(Math.Pow(_base62dict.Count, base62.Length - 1 - base62DigitIndex) * base62CharIndex)

        Next base62DigitIndex

        Return base10

    End Function

End Structure

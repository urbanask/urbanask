Imports System.Security
Imports System.Text.Encoding
Imports System.Web

Public Class createHash

    Protected Const CONNECTION_STRING As String = "Server=SERVER2008;Database=Gabs;uid=login;pwd=everythingcarpetandall;Connect Timeout=600;"

    Private Sub onCreateClick( _
        sender As System.Object, _
        arguments As System.EventArgs) _
        Handles create.Click

        If salt.Text = "" Then

            Dim hasher As New Hashing.hash(username.Text, password.Text)

            salt.Text = hasher.salt
            hash.Text = hasher.hash
            encodedHash.Text = HttpUtility.UrlEncode(hasher.hash)

        Else

            Dim hasher As New Hashing.hash(username.Text, password.Text, "SHA512", salt.Text, 5)

            hash.Text = hasher.hash
            encodedHash.Text = HttpUtility.UrlEncode(hasher.hash)

        End If

    End Sub

    Private Sub createLogins_Click(sender As System.Object, e As System.EventArgs) Handles createLogins.Click

        Me.createLogins.Enabled = False

        Dim vowels() As String = {"a", "e", "i", "o", "u", "oo", "ou", "io", "oe", "ai", "au"},
            prefix() As String = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "qu", "r", "s", "t", "v", "w", "x", "y", "z",
                "br", "bl", "cr", "ch", "cl", "dr", "dw", "fl", "fr", "gr", "gl", "kl", "kr", "pl", "pr", "ph",
                "ps", "sc", "sh", "sk", "sl", "sm", "sn", "skr", "shr", "scr", "sp", "spl", "spr", "squ", "st", "str", "sw", "th",
                "thr", "tr", "tw", "wh"},
            suffix() As String = {"b", "lb", "rb", "mb", "lc", "rc", "d", "ld", "rd", "nd", "rf",
                "f", "lf", "g", "rg", "lge", "ng", "nge", "rge", "th", "lth", "rth", "nth", "sh", "k", "ck", "lk", "nk", "rk", "sk", "wk",
                "l", "m", "lm", "mm", "rm", "sm", "n", "ln", "nn", "rn", "wn", "p", "lp", "mp", "pp", "rp", "sp",
                "r", "rr", "s", "t", "ct", "ft", "lt", "nt", "pt", "rt", "st", "rst", "tt", "wt", "xt", "v", "ve", "rve",
                "w", "x", "y", "z", "zz", "ch", "ph"},
            rnd As New System.Random()

        Using connection As New Data.SqlClient.SqlConnection(CONNECTION_STRING),
            command As New System.Data.SqlClient.SqlCommand("Gabs.login.createUser", connection)

            connection.Open()

            command.CommandType = Data.CommandType.StoredProcedure
            command.CommandTimeout = 60

            command.Parameters.Add("@username", Data.SqlDbType.VarChar, 100)
            command.Parameters.Add("@displayName", Data.SqlDbType.VarChar, 100)
            command.Parameters.Add("@hash", Data.SqlDbType.Char, 44)
            command.Parameters.Add("@salt", Data.SqlDbType.Char, 8)
            command.Parameters.AddWithValue("@iterations", 5)
            command.Parameters.AddWithValue("@hashTypeId", 2)

            For index As Integer = 1 To 100000

                Dim username As String = String.Concat(
                        prefix(rnd.Next(prefix.Length - 1)),
                        vowels(rnd.Next(vowels.Length - 1)),
                        suffix(rnd.Next(prefix.Length - 1)),
                        "-",
                        prefix(rnd.Next(prefix.Length - 1)),
                        vowels(rnd.Next(vowels.Length - 1)),
                        suffix(rnd.Next(prefix.Length - 1))),
                    password As String = username,
                    hasher As New Hashing.hash(username, password)

                command.Parameters("@username").Value = username
                command.Parameters("@displayName").Value = username
                command.Parameters("@hash").Value = hasher.hash
                command.Parameters("@salt").Value = hasher.salt

                command.ExecuteNonQuery()

            Next index

        End Using

        Me.createLogins.Enabled = True

    End Sub

    Private Sub onCreateApiKeyClick(sender As System.Object, e As System.EventArgs) Handles createApiKey.Click

        Dim random As New Cryptography.RNGCryptoServiceProvider(),
            salt(2) As Byte

        random.GetNonZeroBytes(salt)
        apiKey.Text = System.Convert.ToBase64String(salt)

    End Sub

    Private Sub onCreateAuthClick(sender As System.Object, e As System.EventArgs) Handles createAuth.Click

        auth.Text = String.Concat(
            "authorization=",
            toBase64UrlString(
            System.Convert.ToBase64String(
            System.Text.Encoding.UTF8.GetBytes(
            String.Concat(username.Text, ":", password.Text)))))

    End Sub

    Private Sub createDigest_Click(sender As System.Object, e As System.EventArgs) Handles createDigest.Click

        Dim hmac As New Cryptography.HMACSHA1(UTF8.GetBytes(sessionKey.Text)),
            digest As String = toBase64UrlString(
                System.Convert.ToBase64String(
                hmac.ComputeHash(
                UTF8.GetBytes(
                String.Concat(url.Text, sessionId.Text)))))

        Me.digest.Text = sessionId.Text & ":" & digest
        Me.encodedDigest.Text = HttpUtility.UrlEncode(sessionId.Text & ":" & digest)

    End Sub

    Private Function toBase64UrlString(
        base64String As String) As String

        Return base64String.Replace("+"c, "-"c).Replace("/"c, "_"c).Replace("=", "")

    End Function



End Class

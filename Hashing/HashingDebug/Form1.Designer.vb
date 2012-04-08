<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class createHash
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.username = New System.Windows.Forms.TextBox()
        Me.password = New System.Windows.Forms.TextBox()
        Me.create = New System.Windows.Forms.Button()
        Me.usernameLabel = New System.Windows.Forms.Label()
        Me.passwordLabel = New System.Windows.Forms.Label()
        Me.salt = New System.Windows.Forms.TextBox()
        Me.hash = New System.Windows.Forms.TextBox()
        Me.saltLabel = New System.Windows.Forms.Label()
        Me.hashLabel = New System.Windows.Forms.Label()
        Me.apiKey = New System.Windows.Forms.TextBox()
        Me.apiKeyLabel = New System.Windows.Forms.Label()
        Me.createApiKey = New System.Windows.Forms.Button()
        Me.createAuth = New System.Windows.Forms.Button()
        Me.authLabel = New System.Windows.Forms.Label()
        Me.auth = New System.Windows.Forms.TextBox()
        Me.createDigest = New System.Windows.Forms.Button()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.url = New System.Windows.Forms.TextBox()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.sessionId = New System.Windows.Forms.TextBox()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.sessionKey = New System.Windows.Forms.TextBox()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.digest = New System.Windows.Forms.TextBox()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.encodedDigest = New System.Windows.Forms.TextBox()
        Me.encodedHash = New System.Windows.Forms.TextBox()
        Me.createLogins = New System.Windows.Forms.Button()
        Me.SuspendLayout()
        '
        'username
        '
        Me.username.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.username.Location = New System.Drawing.Point(85, 33)
        Me.username.Name = "username"
        Me.username.Size = New System.Drawing.Size(121, 20)
        Me.username.TabIndex = 0
        Me.username.Text = "thinkingstiff"
        '
        'password
        '
        Me.password.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.password.Location = New System.Drawing.Point(284, 33)
        Me.password.Name = "password"
        Me.password.Size = New System.Drawing.Size(121, 20)
        Me.password.TabIndex = 1
        Me.password.Text = "password"
        '
        'create
        '
        Me.create.Location = New System.Drawing.Point(626, 182)
        Me.create.Name = "create"
        Me.create.Size = New System.Drawing.Size(75, 23)
        Me.create.TabIndex = 2
        Me.create.Text = "create"
        Me.create.UseVisualStyleBackColor = True
        '
        'usernameLabel
        '
        Me.usernameLabel.AutoSize = True
        Me.usernameLabel.Location = New System.Drawing.Point(23, 36)
        Me.usernameLabel.Name = "usernameLabel"
        Me.usernameLabel.Size = New System.Drawing.Size(56, 13)
        Me.usernameLabel.TabIndex = 3
        Me.usernameLabel.Text = "username:"
        Me.usernameLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'passwordLabel
        '
        Me.passwordLabel.AutoSize = True
        Me.passwordLabel.Location = New System.Drawing.Point(223, 36)
        Me.passwordLabel.Name = "passwordLabel"
        Me.passwordLabel.Size = New System.Drawing.Size(55, 13)
        Me.passwordLabel.TabIndex = 4
        Me.passwordLabel.Text = "password:"
        Me.passwordLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'salt
        '
        Me.salt.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.salt.Location = New System.Drawing.Point(85, 97)
        Me.salt.Name = "salt"
        Me.salt.Size = New System.Drawing.Size(616, 20)
        Me.salt.TabIndex = 5
        '
        'hash
        '
        Me.hash.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.hash.Location = New System.Drawing.Point(85, 129)
        Me.hash.Name = "hash"
        Me.hash.Size = New System.Drawing.Size(616, 20)
        Me.hash.TabIndex = 6
        '
        'saltLabel
        '
        Me.saltLabel.AutoSize = True
        Me.saltLabel.Location = New System.Drawing.Point(53, 100)
        Me.saltLabel.Name = "saltLabel"
        Me.saltLabel.Size = New System.Drawing.Size(26, 13)
        Me.saltLabel.TabIndex = 7
        Me.saltLabel.Text = "salt:"
        Me.saltLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'hashLabel
        '
        Me.hashLabel.AutoSize = True
        Me.hashLabel.Location = New System.Drawing.Point(46, 132)
        Me.hashLabel.Name = "hashLabel"
        Me.hashLabel.Size = New System.Drawing.Size(33, 13)
        Me.hashLabel.TabIndex = 8
        Me.hashLabel.Text = "hash:"
        Me.hashLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'apiKey
        '
        Me.apiKey.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.apiKey.Location = New System.Drawing.Point(85, 220)
        Me.apiKey.Name = "apiKey"
        Me.apiKey.Size = New System.Drawing.Size(616, 20)
        Me.apiKey.TabIndex = 9
        '
        'apiKeyLabel
        '
        Me.apiKeyLabel.AutoSize = True
        Me.apiKeyLabel.Location = New System.Drawing.Point(35, 223)
        Me.apiKeyLabel.Name = "apiKeyLabel"
        Me.apiKeyLabel.Size = New System.Drawing.Size(44, 13)
        Me.apiKeyLabel.TabIndex = 10
        Me.apiKeyLabel.Text = "api key:"
        '
        'createApiKey
        '
        Me.createApiKey.Location = New System.Drawing.Point(626, 246)
        Me.createApiKey.Name = "createApiKey"
        Me.createApiKey.Size = New System.Drawing.Size(75, 23)
        Me.createApiKey.TabIndex = 11
        Me.createApiKey.Text = "create"
        Me.createApiKey.UseVisualStyleBackColor = True
        '
        'createAuth
        '
        Me.createAuth.Location = New System.Drawing.Point(626, 301)
        Me.createAuth.Name = "createAuth"
        Me.createAuth.Size = New System.Drawing.Size(75, 23)
        Me.createAuth.TabIndex = 14
        Me.createAuth.Text = "create"
        Me.createAuth.UseVisualStyleBackColor = True
        '
        'authLabel
        '
        Me.authLabel.AutoSize = True
        Me.authLabel.Location = New System.Drawing.Point(35, 278)
        Me.authLabel.Name = "authLabel"
        Me.authLabel.Size = New System.Drawing.Size(31, 13)
        Me.authLabel.TabIndex = 13
        Me.authLabel.Text = "auth:"
        '
        'auth
        '
        Me.auth.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.auth.Location = New System.Drawing.Point(85, 275)
        Me.auth.Name = "auth"
        Me.auth.Size = New System.Drawing.Size(616, 20)
        Me.auth.TabIndex = 12
        '
        'createDigest
        '
        Me.createDigest.Location = New System.Drawing.Point(626, 460)
        Me.createDigest.Name = "createDigest"
        Me.createDigest.Size = New System.Drawing.Size(75, 23)
        Me.createDigest.TabIndex = 17
        Me.createDigest.Text = "create"
        Me.createDigest.UseVisualStyleBackColor = True
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(58, 333)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(21, 13)
        Me.Label1.TabIndex = 16
        Me.Label1.Text = "url:"
        '
        'url
        '
        Me.url.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.url.Location = New System.Drawing.Point(85, 330)
        Me.url.Name = "url"
        Me.url.Size = New System.Drawing.Size(616, 20)
        Me.url.TabIndex = 15
        Me.url.Text = "http://localhost/api/questions/columns"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(25, 359)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(54, 13)
        Me.Label2.TabIndex = 19
        Me.Label2.Text = "sessionId:"
        '
        'sessionId
        '
        Me.sessionId.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.sessionId.Location = New System.Drawing.Point(85, 356)
        Me.sessionId.Name = "sessionId"
        Me.sessionId.Size = New System.Drawing.Size(616, 20)
        Me.sessionId.TabIndex = 18
        Me.sessionId.Text = "677814a9-1e60-4715-bdd1-0a34b82075a0"
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(16, 385)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(63, 13)
        Me.Label3.TabIndex = 21
        Me.Label3.Text = "sessionKey:"
        '
        'sessionKey
        '
        Me.sessionKey.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.sessionKey.Location = New System.Drawing.Point(85, 382)
        Me.sessionKey.Name = "sessionKey"
        Me.sessionKey.Size = New System.Drawing.Size(616, 20)
        Me.sessionKey.TabIndex = 20
        Me.sessionKey.Text = "f238df06-abd0-42f7-a4b8-cc01df78fd38"
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.Location = New System.Drawing.Point(25, 411)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(53, 13)
        Me.Label4.TabIndex = 23
        Me.Label4.Text = "x-session:"
        '
        'digest
        '
        Me.digest.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.digest.Location = New System.Drawing.Point(85, 408)
        Me.digest.Name = "digest"
        Me.digest.Size = New System.Drawing.Size(616, 20)
        Me.digest.TabIndex = 22
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Location = New System.Drawing.Point(27, 437)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(52, 13)
        Me.Label5.TabIndex = 25
        Me.Label5.Text = "encoded:"
        '
        'encodedDigest
        '
        Me.encodedDigest.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.encodedDigest.Location = New System.Drawing.Point(85, 434)
        Me.encodedDigest.Name = "encodedDigest"
        Me.encodedDigest.Size = New System.Drawing.Size(616, 20)
        Me.encodedDigest.TabIndex = 24
        '
        'encodedHash
        '
        Me.encodedHash.Font = New System.Drawing.Font("Courier New", 8.25!)
        Me.encodedHash.Location = New System.Drawing.Point(85, 155)
        Me.encodedHash.Name = "encodedHash"
        Me.encodedHash.Size = New System.Drawing.Size(616, 20)
        Me.encodedHash.TabIndex = 26
        '
        'createLogins
        '
        Me.createLogins.Location = New System.Drawing.Point(626, 12)
        Me.createLogins.Name = "createLogins"
        Me.createLogins.Size = New System.Drawing.Size(75, 23)
        Me.createLogins.TabIndex = 27
        Me.createLogins.Text = "create logins"
        Me.createLogins.UseVisualStyleBackColor = True
        '
        'createHash
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(717, 509)
        Me.Controls.Add(Me.createLogins)
        Me.Controls.Add(Me.encodedHash)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.encodedDigest)
        Me.Controls.Add(Me.Label4)
        Me.Controls.Add(Me.digest)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.sessionKey)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.sessionId)
        Me.Controls.Add(Me.createDigest)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.url)
        Me.Controls.Add(Me.createAuth)
        Me.Controls.Add(Me.authLabel)
        Me.Controls.Add(Me.auth)
        Me.Controls.Add(Me.createApiKey)
        Me.Controls.Add(Me.apiKeyLabel)
        Me.Controls.Add(Me.apiKey)
        Me.Controls.Add(Me.hashLabel)
        Me.Controls.Add(Me.saltLabel)
        Me.Controls.Add(Me.hash)
        Me.Controls.Add(Me.salt)
        Me.Controls.Add(Me.passwordLabel)
        Me.Controls.Add(Me.usernameLabel)
        Me.Controls.Add(Me.create)
        Me.Controls.Add(Me.password)
        Me.Controls.Add(Me.username)
        Me.Name = "createHash"
        Me.Text = "hash"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents username As System.Windows.Forms.TextBox
    Friend WithEvents password As System.Windows.Forms.TextBox
    Friend WithEvents create As System.Windows.Forms.Button
    Friend WithEvents usernameLabel As System.Windows.Forms.Label
    Friend WithEvents passwordLabel As System.Windows.Forms.Label
    Friend WithEvents salt As System.Windows.Forms.TextBox
    Friend WithEvents hash As System.Windows.Forms.TextBox
    Friend WithEvents saltLabel As System.Windows.Forms.Label
    Friend WithEvents hashLabel As System.Windows.Forms.Label
    Friend WithEvents apiKey As System.Windows.Forms.TextBox
    Friend WithEvents apiKeyLabel As System.Windows.Forms.Label
    Friend WithEvents createApiKey As System.Windows.Forms.Button
    Friend WithEvents createAuth As System.Windows.Forms.Button
    Friend WithEvents authLabel As System.Windows.Forms.Label
    Friend WithEvents auth As System.Windows.Forms.TextBox
    Friend WithEvents createDigest As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents url As System.Windows.Forms.TextBox
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents sessionId As System.Windows.Forms.TextBox
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents sessionKey As System.Windows.Forms.TextBox
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents digest As System.Windows.Forms.TextBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents encodedDigest As System.Windows.Forms.TextBox
    Friend WithEvents encodedHash As System.Windows.Forms.TextBox
    Friend WithEvents createLogins As System.Windows.Forms.Button

End Class

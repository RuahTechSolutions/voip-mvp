var apn = require('apn')
var express = require('express')
var app = express()

let deviceTokens = ["dlee2a753d5a2769d962e48e67c4749059936daeced0ba1303385715aa7eff3f",
    "179b0dc13d6969933e779b53bb721ac6bd832decb33611e142955433d4df401f",
    "428cfc1463a185d9fa060a3149c2a973b3d563b06e23bbeb512ac7e6fd3fb7ad"
]

app.use(express.json())

function configure() {
    var options = {
        token: {
            key: "AuthKey_TXCPTLQB58.p8",
            keyId: "TXCPTLQB58",
            teamId: "LBA58EFBZF"
        },
        production: false
    };

    var apnProvider = new apn.Provider(options);
    return apnProvider;
}

function sendNotification(apnProvider, deviceToken, title = "Incoming Call", body = "You have an incoming VoIP call") {
    var note = new apn.Notification();

    note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
    note.badge = 1;
    note.alert = {
        title: title,
        body: body
    };
    note.payload = {
        'voip': true,
        'callId': 'call-' + Date.now(),
        'from': 'Test Caller'
    };
    note.topic = "com.ruah.voip.test.voip";
    note.pushType = "voip";

    apnProvider.send(note, deviceToken).then((result) => {
        console.log("Sent:", result.sent.length);
        console.log("Failed:", result.failed.length);
        if (result.failed.length > 0) {
            console.log("Failed tokens:", result.failed);
        }
    });
}

// Endpoint to register/update device token
app.post('/register-token', (req, res) => {
    const { token } = req.body;

    if (!token) {
        return res.status(400).json({ error: 'Token is required' });
    }

    if (!deviceTokens.includes(token)) {
        deviceTokens.push(token);
        console.log(`New token registered: ${token}`);
    }

    res.json({
        success: true,
        message: 'Token registered',
        tokens: deviceTokens.length
    });
});

// Endpoint to send notification to all registered devices
app.post('/send-notification', (req, res) => {
    const { title = "Incoming Call", body = "You have an incoming VoIP call" } = req.body;

    if (deviceTokens.length === 0) {
        return res.status(400).json({ error: 'No registered tokens' });
    }

    try {
        let apnProvider = configure();

        let sentCount = 0;
        deviceTokens.forEach(token => {
            sendNotification(apnProvider, token, title, body);
            sentCount++;
        });

        res.json({
            success: true,
            message: `Notification sent to ${sentCount} device(s)`,
            count: sentCount
        });

        // Shutdown after a short delay to allow notifications to be sent
        setTimeout(() => {
            apnProvider.shutdown();
        }, 1000);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint to send notification to specific token
app.post('/send-to-token', (req, res) => {
    const { token, title = "Incoming Call", body = "You have an incoming VoIP call" } = req.body;

    if (!token) {
        return res.status(400).json({ error: 'Token is required' });
    }

    try {
        let apnProvider = configure();
        sendNotification(apnProvider, token, title, body);

        res.json({
            success: true,
            message: 'Notification sent',
            token: token
        });

        // Shutdown after a short delay
        setTimeout(() => {
            apnProvider.shutdown();
        }, 1000);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint to list all registered tokens
app.get('/tokens', (req, res) => {
    res.json({
        count: deviceTokens.length,
        tokens: deviceTokens
    });
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', registeredTokens: deviceTokens.length });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`VoIP Notification Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Registered tokens: ${deviceTokens.length}`);
});
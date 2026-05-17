const express = require("express");

const app = express();

app.use(express.json());

const PORT = process.env.PORT || 3000;

const config = {
  nodeEnv: process.env.NODE_ENV || "development",
  dbHost: process.env.DB_HOST || "not-configured",
  dbPort: process.env.DB_PORT || "5432",
  dbName: process.env.DB_NAME || "not-configured",
  receiptBucket: process.env.RECEIPT_BUCKET || "not-configured",
  awsRegion: process.env.AWS_REGION || "not-configured",
};

function log(level, message, extra = {}) {
  console.log(
    JSON.stringify({
      timestamp: new Date().toISOString(),
      level,
      service: "kk-payments",
      message,
      ...extra,
    })
  );
}

app.get("/", (req, res) => {
  res.status(200).json({
    service: "kk-payments",
    status: "running",
    environment: config.nodeEnv,
  });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    service: "kk-payments",
    environment: config.nodeEnv,
    timestamp: new Date().toISOString(),
  });
});

app.get("/config", (req, res) => {
  res.status(200).json({
    service: "kk-payments",
    environment: config.nodeEnv,
    dbHost: config.dbHost,
    dbPort: config.dbPort,
    dbName: config.dbName,
    receiptBucket: config.receiptBucket,
    awsRegion: config.awsRegion,
  });
});

app.post("/payments", (req, res) => {
  const { amount, currency = "KES", customerPhone } = req.body;

  if (!amount || !customerPhone) {
    log("warn", "Invalid payment request", {
      reason: "amount and customerPhone are required",
    });

    return res.status(400).json({
      success: false,
      error: "amount and customerPhone are required",
    });
  }

  const receipt = {
    receiptId: `kk-${Date.now()}`,
    amount,
    currency,
    customerPhone,
    environment: config.nodeEnv,
    receiptBucket: config.receiptBucket,
    createdAt: new Date().toISOString(),
  };

  log("info", "Payment processed", {
    receiptId: receipt.receiptId,
    amount,
    currency,
    receiptBucket: config.receiptBucket,
  });

  return res.status(201).json({
    success: true,
    message: "Payment processed successfully",
    receipt,
  });
});

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: "Endpoint not found",
  });
});

app.listen(PORT, () => {
  log("info", "kk-payments service started", {
    port: PORT,
    environment: config.nodeEnv,
    dbHost: config.dbHost,
    receiptBucket: config.receiptBucket,
  });
});
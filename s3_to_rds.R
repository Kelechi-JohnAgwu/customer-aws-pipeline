library(paws.storage)
library(DBI)
library(RPostgres)

message("Connecting to Amazon S3...")

# Create our S3 client
s3 <- s3()

# Retrieve the actual CSV object
response <- s3$get_object(
  Bucket = "customer-pipeline-kja-2026",
  Key = "raw/customers.csv"
)

# Convert the downloaded bytes into an R data frame
customers <- read.csv(
  text = rawToChar(response$Body)
)

# Transform the customer data
customers$city <- toupper(customers$city)

message("Transformation completed!")

print(customers)

message("Connecting to Amazon RDS...")

con <- dbConnect(
  Postgres(),
  host = Sys.getenv("RDS_HOST"),
  port = 5432,
  dbname = "customer_db",
  user = "postgres",
  password = Sys.getenv("RDS_PASSWORD")
)

# Write our in-memory data frame directly to RDS
dbWriteTable(
  con,
  "customers_direct",
  customers,
  overwrite = TRUE,
  row.names = FALSE
)

dbDisconnect(con)

message("S3 to RDS pipeline completed successfully!")

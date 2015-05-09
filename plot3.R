##This script examine how household energy usage varies from the dates 2007-02-01 and 2007-02-02 and constructs plot3
##1 - Checks if the required packages are installed, if they are not it installs them
##2 - Loads the required libraries
##3 - Checks if the directory "data" exists if it does not exist it is created
##4 - Checks if household_power_consumption.txt file exists, if it does not exist it downloads the correspondent zip file and unzips it
##5 - Extracts/Loads into R only data measurements of electric power consumption in one household with a one-minute sampling rate from 
##    the period between 2007-02-01 and 2007-02-02 
##6 - From the resulting data frame created in step 5, converts the Date and Time variables to Date/Time classes in R and adds 
##    to that data frame a new Date_Time variable 
##7 - Constructs the plot and saves it as plot3.png file.
plot3  <- function(){
       
        ##Checks if the required packages are installed, if they are not it installs them
        if("data.table" %in% rownames(installed.packages()) == FALSE) {install.packages("data.table")}
        if("reshape2" %in% rownames(installed.packages()) == FALSE) {install.packages("reshape2")}
        if("sqldf" %in% rownames(installed.packages()) == FALSE) {install.packages("sqldf")}
        
        ##Loads the required libraries
        library(data.table)
        library(sqldf)
        
        ## Check if the directory "data" exists if it does not exist it is created
        if(!file.exists("./data")){dir.create("./data")}
        
        
        ## Code for reading the data
        
        ## Check if the power consumption txt file exists if it does not exist it downloads the correspondent zip file and unzip it
        if(!file.exists("./data/household_power_consumption.txt")) {
                
                fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
                os <- Sys.info()['sysname'] 
                
                if (!os %in% "Windows") 
                        download.file(fileUrl, destfile ="./data/household_power_consumption.zip", method = "curl")
                else 
                        download.file(fileUrl, destfile ="./data/household_power_consumption.zip")
                
                ##unzip file
                unzip ("./data/household_power_consumption.zip", exdir = "./data")
        }
        
        ##open connection to file 
        powerCfile_con <- file("./data/household_power_consumption.txt")
        ##query and load data from the dates 2007-02-01 and 2007-02-02.
        powerC_df <- sqldf("select * from powerCfile_con where Date in ('1/2/2007', '2/2/2007')", file.format = list(header = TRUE, sep = ";"))
        ##close connection
        close(powerCfile_con)
        
        ##convert the Date and Time variables to Date/Time classes
        powerC_df$Date <- as.Date(powerC_df$Date, format="%d/%m/%Y")
        date_time <- as.POSIXct(strptime((paste(powerC_df$Date, powerC_df$Time)), format = "%Y-%m-%d %H:%M:%S"))
        
        ##create a new column to add the date_time variable
        powerC_df$Date_Time  <- date_time
        
        
        ##Code for constructing the plot and save it to a PNG file 
        
        #Open PNG device; create 'plot3.png' in my working directory
        png(filename = "plot3.png", width = 480, height = 480)
        
        ##Create plot3 that is sent to the plot3.png file
        with(powerC_df, plot(Date_Time, Sub_metering_1, type="l",
                  ylab="Energy sub metering", xlab=""))
        with(powerC_df, lines(Date_Time, Sub_metering_2, col="red"))
        with(powerC_df, lines(Date_Time, Sub_metering_3, col="blue"))
        legend("topright", col = c("black", "red", "blue"), lty = 1,
               legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
        
        ##Close the png device
        dev.off()
        
        print("Plot created! Please look for the plot3.png file under your current working directory.")
}
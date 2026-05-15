install.packages(c("assertthat", "dreamerr"))

library(arrow)
library(data.table)
library(fixest)
library(ggplot2)


#model_df <- read_parquet(file.path(file_path, file_name))
model_df <- read_parquet("model_dataset.parquet")

model_df <- as.data.table(model_df)

model_df[, datetime := as.POSIXct(
  paste0(
    date, " ",
    sprintf("%02d:00:00", as.integer(model_df$hour))
  ),
  tz = "UTC"
)]
head(model_df)
View(model_df)


model_df[, block_id := factor(block_id)]
model_df

#data understanding of model_df
summary(model_df)
unique(model_df$crime_count)

length(which(model_df$crime_count == 2))
length(which(model_df$crime_count == 3))
length(which(model_df$crime_count == 1))
length(which(model_df$crime_count == 13))

dim(model_df)
names(model_df)

model_df_duplicate <- model_df[duplicated(model_df)]


# plots

plot(model_df$Temperature)

ggplot(df, aes(x = datetime, y = Temperature)) +
  geom_line() +
  labs(
    title = "Temperature Over Time",
    x = "Time",
    y = "Temperature (°C)"
  ) +
  theme_minimal()


setFixest_nthreads()

est <- feols(
  crime_count ~ adjacent * post_rule_change * is_game_hour +
    attendance + Wind + Visibility + Temperature + Precipitation |
    block_id + datetime,
  data    = model_df,
  cluster = ~ block_id
)

summary(est)



# Run again with log(crime_count)
model_df$crime_rate = model_df$crime_count + 1
model_df$log_crime_rate = log(model_df$crime_rate)

est_log <- feols(
  log_crime_rate ~ adjacent * post_rule_change * is_game_hour +
    attendance + Wind + Visibility + Temperature + Precipitation |
    block_id + datetime,
  data    = model_df,
  cluster = ~ block_id
)

summary(est_log)



# Poisson w/ fixed effects
est_ppml <- fepois(
  crime_count ~ adjacent * post_rule_change * is_game_hour +
    attendance + Wind + Visibility + Temperature + Precipitation |
    block_id + datetime,
  data    = model_df,
  cluster = ~ block_id
)

summary(est_ppml)

#Data Understanding

str(model_df$crime_count)
model_df$crime_count <- as.numeric(model_df$crime_count)
model_df$crime_count <- as.numeric(as.character(model_df$crime_count))
nrow(model_df)
summary(model_df$crime_count)
sum(is.na(model_df$crime_count))

ggplot() +
  geom_histogram(
    data = model_df,
    aes(x = crime_count),
    bins = 40,
    fill = "steelblue",
    color = "white"
  ) +
  labs(
    title = "Distribution of Crime Counts",
    x = "Crime Count per Block-Hour",
    y = "Frequency"
  ) +
  theme_minimal()

ggplot(model_df, aes(x = factor(adjacent), y = crime_count)) +
  geom_boxplot(fill = "grey80") +
  labs(
    title = "Crime Distribution by Block Proximity",
    x = "Block Type",
    y = "Crime Count"
  ) +
  scale_x_discrete(labels = c("Control", "Adjacent")) +
  theme_minimal()

model_df$date_only <- as.Date(model_df$datetime)

df_time <- aggregate(
  crime_count ~ date_only,
  data = model_df,
  FUN = mean
)

ggplot(df_time, aes(x = date_only, y = crime_count)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Average Crime Over Time",
    x = "Date",
    y = "Average Crime per Block-Hour"
  ) +
  theme_minimal()




#Data visualization
df_ddd <- summarise(
  group_by(
    model_df,
    adjacent,
    is_game_hour,
    post_rule_change
  ),
  crime = mean(crime_count, na.rm=TRUE),
  .groups = "drop"
)

library(ggplot2)

ggplot(
  df_ddd,
  aes(
    x = factor(post_rule_change),
    y = crime,
    color = factor(adjacent),
    group = factor(adjacent)
  )
) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_wrap(
    ~ is_game_hour,
    labeller = labeller(
      is_game_hour = c(
        "FALSE" = "Non-Game Hours",
        "TRUE"  = "Game Hours"
      )
    )
  ) +
  labs(
    title = "Triple-Difference Visualization: Pitch Clock Rule & Local Crime",
    subtitle = "Adjacent vs Control Blocks, Pre vs Post Rule Change",
    x = "Period",
    y = "Average Crime per Block-Hour",
    color = "Block Type"
  ) +
  scale_x_discrete(
    labels = c(
      "FALSE" = "Pre-R(2022)",
      "TRUE"  = "Post-R(2023)"
    )
  ) +
  scale_color_manual(
    values = c("0" = "grey40", "1" = "red"),
    labels = c("Control Blocks", "Adjacent Blocks")
  ) +
  theme_minimal()

names(model_df)
model_df$hour <- as.integer(format(as.POSIXct(model_df$datetime), "%H"))


# Try OLS at daily granularity
library(dplyr)
library(lubridate)

daily_df <- model_df %>%
  mutate(date = as.Date(datetime)) %>%
  group_by(block_id, date) %>%
  summarize(
    crime_count = sum(crime_count, na.rm = TRUE),
    
    # Typically constant within a day, but safe to average:
    attendance = mean(attendance, na.rm = TRUE),
    Wind = mean(Wind, na.rm = TRUE),
    Visibility = mean(Visibility, na.rm = TRUE),
    Temperature = mean(Temperature, na.rm = TRUE),
    Precipitation = mean(Precipitation, na.rm = TRUE),
    
    # Game-related variables — if *any* hour is a game hour:
    is_game_hour = max(is_game_hour, na.rm = TRUE),
    
    # Same logic for rule-change period:
    post_rule_change = max(post_rule_change, na.rm = TRUE),
    is_night_game = max(is_night_game, na.rm = TRUE),
    
    # adjacency is constant for block_id, so just keep the first:
    adjacent = first(adjacent)
  ) %>%
  ungroup()


library(fixest)

est_daily <- feols(
  crime_count ~ adjacent * post_rule_change * is_game_hour +
    attendance + Wind + Visibility + Temperature + Precipitation |
    block_id + date,
  data = daily_df,
  cluster = ~ block_id
)

summary(est_daily)


# Poisson w/ fixed effects
est_ppml_daily <- fepois(
  crime_count ~ adjacent * post_rule_change * is_game_hour +
    attendance + Wind + Visibility + Temperature + Precipitation |
    block_id + date,
  data    = daily_df,
  cluster = ~ block_id
)

summary(est_ppml_daily)


# Poisson for night games only
night_df <- daily_df %>%
  filter(is_night_game == 1)

est_ppml_daily_night <- fepois(
  crime_count ~ adjacent * post_rule_change * is_game_hour +
    attendance + Wind + Visibility + Temperature + Precipitation |
    block_id + date,
  data    = night_df,
  cluster = ~ block_id
)

summary(est_ppml_daily_night)

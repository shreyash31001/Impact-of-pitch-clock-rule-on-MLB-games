# The 2023 MLB Pitch Clock Rule and Local Crime Patterns: A Data-Driven Causal Analysis
# Project Overview

This project investigates whether the implementation of the Major League Baseball (MLB) Pitch Clock Rule in 2023 had an unintended impact on crime rates near Dodger Stadium in Los Angeles. Specifically, the study examines whether shorter baseball games led to increased crime in surrounding areas during and immediately after games.

The motivation behind this research stems from previous studies showing that reduced time between the end of alcohol sales and spectators leaving stadiums can increase post-event crime. Since the MLB pitch clock shortened game durations by approximately 24 minutes on average, this project explores whether the change created measurable differences in local crime activity.

Using a causal inference framework, this study combines crime, sports, weather, and geographic datasets to understand how policy changes in sports can indirectly influence public safety.

# Problem Statement

In 2023, MLB introduced a new pitch clock rule to make games faster and improve fan engagement. While the rule improved viewing experience, it also unintentionally shortened the duration between:

Last alcohol sales inside the stadium
Game completion and crowd exit

Prior research suggests this shorter interval may increase the likelihood of alcohol-related crime after games.

# This project answers the following research question:

Did the MLB pitch clock rule increase crime in areas surrounding Dodger Stadium during and immediately after home games?

# Why This Project Matters

This project extends beyond sports analytics and enters the fields of:

Urban safety
Public policy
Event management
Crime analytics
Behavioral economics

Understanding how large sporting events influence crime helps organizations and governments make smarter decisions regarding:

Local Governments
Police staffing allocation
Public safety planning
Traffic and crowd management
Event scheduling policies
Stadium Operators & Sports Franchises
Security deployment
Alcohol sales strategies
Fan safety initiatives
Emergency preparedness
Policymakers
Evidence-based decision-making regarding public events
Crime prevention strategies during high-attendance gatherings

This study demonstrates how data science can be applied to solve real-world societal problems using causal inference and geospatial analytics.

# Business Objective:

The primary objective of this project was to determine whether a policy change in professional sports (pitch clock implementation) had a statistically measurable effect on crime rates in nearby neighborhoods.

# The project aimed to:

Measure changes in crime near the stadium before and after the rule implementation.
Compare treatment areas (close to the stadium) with control areas (farther away).
Identify whether crime specifically increased during game hours.
Establish whether the observed effect could be interpreted causally rather than correlational.
Data Sources

# To build a reliable and comprehensive analytical framework, multiple real-world datasets were integrated.

# 1. Los Angeles Police Department Crime Data

Used to measure crime occurrences around Dodger Stadium.

# Dataset Information

~467,000+ crime records
Includes:
Crime type
Timestamp
Latitude & longitude
Incident location

# Purpose
This served as the dependent variable (crime count) for the analysis.

# 2. U.S. Census TIGER/Line Shapefiles

Used for geographic segmentation.

# Purpose

Defined census blocks around Dodger Stadium
Helped classify:
Treatment zones (within 700 meters)
Control zones (within 1600 meters)

This enabled a geospatial comparison framework.

# 3. Retrosheet MLB Game Logs (2022–2023)

Contained historical MLB game information.

# Included:

Game dates
Start times
Duration
Attendance
Teams
Stadium location

# Purpose
Used to identify:

Dodgers home games
Game duration changes
Game-hour activity periods
4. NOAA Weather Data

# Included environmental variables such as:

Temperature
Wind speed
Precipitation
Visibility

Purpose
Weather conditions can influence crowd behavior and crime patterns. Including these variables reduced omitted-variable bias.

# Data Engineering & Preprocessing Pipeline

A significant portion of the project involved transforming raw multi-source datasets into a unified analytical dataset.

# Step 1: Data Filtering

Only 2022 and 2023 records were retained.

Why?

2022 = Pre-treatment period
2023 = Post-treatment period

This created a natural before-and-after experiment.

# Step 2: Temporal Standardization

All timestamps were standardized to:

Pacific Standard Time (PST)

Hours were rounded down.

Example:

Original Time	Converted Hour
08:37 PM	08:00 PM

This ensured consistent hourly aggregation.

# Step 3: Geospatial Mapping

Using latitude and longitude coordinates:

Crimes were spatially joined to census blocks
Geographic distances from Dodger Stadium were calculated

# Blocks were categorized as:

Treatment Group

Within 700 meters

These areas were expected to experience the highest game-related spillover effects.

Control Group

Within 1600 meters

Used as a comparison benchmark.

# Final segmentation:

30 treatment blocks
241 control blocks
Step 4: Feature Engineering

Several meaningful features were created.

adjacent

# Binary variable:

1 → close to stadium
0 → control block
post_rule_change

Indicates whether the pitch clock rule existed.

0 → 2022
1 → 2023
is_game_hour

Indicates whether crime occurred during or immediately after a Dodgers home game.

attendance

Fan attendance per game.

Higher attendance could influence crowd congestion and crime probability.

Weather Variables

# Added:

Wind
Temperature
Precipitation
Visibility

to control for environmental effects.

Dataset Scale

The final merged dataset consisted of:

Hour-Level Dataset

4.7 million+ records

11 features

Used for high-granularity analysis.

Day-Level Dataset

197,830 records

10 features

Used to reduce sparsity for count-based modeling.

This highlights the project's ability to handle large-scale real-world data integration and transformation.

# Methodology: Causal Inference Approach

One of the strongest aspects of this project is the use of a Triple Difference (DDD) causal framework, commonly used in economics and policy evaluation.

Instead of simply checking whether crime increased, the project isolates the effect of the pitch clock by comparing:

Dimension 1: Location
Near stadium
Farther from stadium
Dimension 2: Time Period
Before rule change
After rule change
Dimension 3: Event Timing
Game hours
Non-game hours

# This design helps answer:

Did crime near the stadium increase specifically during game hours after the pitch clock rule?

rather than simply observing general crime changes.

This improves causal validity and reduces bias.

# Statistical Models Used
1. Ordinary Least Squares (OLS)

OLS was used as the baseline econometric model.

# Purpose:

Estimate treatment effect
Identify statistically significant changes in crime

# Advantages:

Interpretable
Strong baseline model
Works well with fixed effects

# Limitations:

Crime data is sparse
Many zero-count observations
2. Poisson Pseudo-Maximum Likelihood (PPML)

Since crime is a count variable, PPML was used.

Why PPML?

# Crime data:

Cannot be negative
Contains many zeros
Shows heteroskedasticity

PPML handles these issues better than standard regression.

This makes it more suitable for:

rare-event prediction problems

commonly found in:

fraud detection
insurance claims
healthcare events
crime analytics
Model Controls

To reduce bias, the models included:

Fixed Effects

To account for:

Block-level effects

Neighborhood characteristics

Date-level effects

Holidays, weekends, city-wide events

Weather Controls

To remove environmental influence.

Attendance Controls

To account for crowd size.

This increased model reliability and interpretability.

Results
OLS Findings

The causal effect coefficient was:

Positive but extremely small

# Key Result:

Not statistically significant
p-value ≈ 0.998

# Interpretation:

No meaningful evidence that the pitch clock increased crime.

PPML Findings

# PPML suggested:

~28.4% increase in crimes near stadium blocks after the rule change

However:

p-value ≈ 0.128
Not statistically significant at 5% threshold

# Interpretation:

Although results were directionally positive, the evidence was insufficient to confidently conclude that the pitch clock caused increased crime.

Key Insights

# The project produced three major insights:

1. Shorter Games Did Not Statistically Increase Crime

The evidence does not support a strong causal relationship.

2. Sparse Crime Data is Challenging

Crime occurrences were extremely low at hourly levels.

This justified:

count models
aggregation methods
robustness testing
3. Policy Changes Can Have Hidden Externalities

Even entertainment-related rules may affect:

crowd behavior
public safety
policing needs
Business & Societal Impact

Although no significant causal effect was found, the findings remain valuable.

For Sports Organizations

Helps evaluate whether operational changes affect public safety.

For Police Departments

Supports evidence-based staffing decisions during sporting events.

For Urban Planners

Improves crowd management understanding.

For Researchers

Creates a framework for studying:

concerts
festivals
NFL/NBA events
alcohol-related behavioral changes
Challenges Faced
Data Sparsity

Most census block-hours had zero crimes.

Geospatial Complexity

Mapping crimes accurately to census blocks required:

spatial joins
coordinate reference systems
polygon distance calculations
Causal Identification

Separating true treatment effects from unrelated crime trends required rigorous econometric controls.

Future Scope

This project can be expanded significantly.

Multi-Stadium Analysis

Include:

Yankees Stadium
Wrigley Field
Fenway Park

to improve generalizability.

Different Sports

Analyze:

NFL
NBA
concerts
Advanced Models

Future improvements:

Spatial Econometrics
Bayesian Causal Models
Time-Series Intervention Models
Machine Learning for Crime Forecasting
Additional Variables

Include:

alcohol sales data
policing intensity
ride-sharing activity
parking lot density
local business traffic
Tech Stack

Programming & Analysis

Python
Statistical Modeling

Libraries & Tools

Pandas
GeoPandas
NumPy
Statsmodels

Geospatial Processing

Spatial Joins
Coordinate Reference Systems (CRS)

Econometric Methods

Triple Difference (DDD)
OLS Regression
PPML Regression

Data Sources

LAPD Crime Data
NOAA Weather
MLB Retrosheet Logs
U.S. Census Shapefiles

# API Performance Benchmark Suite

## Overview
A comparative benchmark of different Java REST implementations, refactored by **Youssef Bahaddou**.
Measures implementation overhead and performance differences between frameworks.

## Modules
- **benchmark-common**: Shared Data Models (BenchmarkCustomer, BenchmarkAccount).
- **variante-a-jersey**: JAX-RS (Jersey) Implementation.
- **variante-c-springboot-mvc**: Spring Web MVC Implementation.
- **variante-d-springdata-rest**: Spring Data REST Implementation.

## How to Run
1. Build all modules:
   \\\ash
   mvn clean package
   \\\
2. Deploy desired variant (war or jar).
3. Run JMeter scripts located in \jmeter/\.

## Author
Youssef Bahaddou


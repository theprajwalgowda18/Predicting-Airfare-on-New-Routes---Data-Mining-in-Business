Description:
This project focused on predictive modeling to estimate airfare on new airline routes using historical data. It aimed to address congestion challenges from airline deregulation in the 1990s by optimizing pricing strategies. Models were developed using Analytic Solver, SAP Analytics Cloud, and R to ensure robust evaluation and actionable insights.

Key Highlights

Objective:
 • Investigated factors influencing airfare, such as route competition, distance, and the presence of Southwest Airlines (SW).
 • Automated airfare predictions to support aviation consulting strategies and enhance operational efficiency.

Data Preparation:
 • Preprocessing Techniques:
 • Median imputation for outliers (e.g., population metrics).
 • Mode and mean imputation for categorical and numerical variables.
 • Data Partitioning:
 • Split the dataset into Training (50%), Validation (30%), and Testing (20%) to evaluate model performance effectively.

Model Development:
 • Models Implemented:
 • Linear Regression, Decision Tree, Neural Networks, and K-Nearest Neighbors (KNN).
 • Best Model: Linear Regression delivered strong performance:
 • R²: 80% (Training), 79% (Validation), 70% (Testing).
 • RMSE: 34 (Training), 38 (Testing).
 • SW’s presence reduced fares by approximately $44, highlighting its competitive impact.

Platform Comparison:
 • SAP Analytics Cloud:
 • Achieved the lowest RMSE (25.49) with a prediction confidence of 95.59%.
 • RStudio:
 • Enhanced model interpretability through stepwise regression and detailed feature selection.

Business Insights:
 • SW’s presence significantly lowered fares, showcasing its competitive pressure in the airline industry.


Impact:
This project demonstrates the potential of data-driven strategies in optimizing airfare predictions, providing airlines and consultants with actionable insights to improve pricing models and customer satisfaction.

# Personal Budget Tracker - Flutter Project

## Overview
The **Personal Budget Tracker** is a mobile application built using Flutter. It allows users to track their expenses and manage their budget through a user-friendly interface, with key features like expense categorization and visualizations for a clear financial overview.

## Learning Goals
My main goal for this project was to gain hands-on experience with Flutter, especially with UI design, state management, and integrating chart libraries to create an intuitive experience for users. This was my first significant project in Flutter, so I was excited to explore how Flutter’s framework could be used to build effective and visually appealing applications.

## Features
- **Dashboard**: An overview of budget and expenses with visual charts
- **Expense Detail Screen**: Adding and viewing individual expenses
- **Expense Categorization**: Organizes expenses by type
- **Data Persistence**: Local storage using SQLite/shared preferences
- **Charts**: Visual representation of budget data using Syncfusion Flutter Charts (version 27.1.56)

## Code and Design Choices
- **Syncfusion Charts**: Chose Syncfusion due to its flexibility in visualizing budget data and ease of integration with Flutter.
- **State Management**: Managed state with Flutter’s built-in stateful widgets for simplicity and efficiency.
- **Data Persistence**: Used SQLite for storing data locally, allowing the user’s budget data to remain accessible even after app closure.
- **UI**: Designed for ease of use, ensuring users could access expense details, summaries, and charts without navigating multiple screens.

## Challenges
### Chart Integration
The primary challenge was getting charts to display data effectively. Integrating Syncfusion charts required careful alignment of data models with the chart library, as it’s essential to ensure the app could pull and display data accurately.

### Approach to Solving Challenges
1. **Documentation & Community Resources**: I explored Syncfusion documentation and Flutter forums to understand best practices for chart integration.
2. **Experimentation**: Tried various chart types and configurations to find the best fit for representing budget data effectively.
3. **Refinement**: Through testing, I fine-tuned chart properties for better readability and performance.

## Repository
This project is public on GitHub. You can view it here: [GitHub Link to Flutter Project](#)

---
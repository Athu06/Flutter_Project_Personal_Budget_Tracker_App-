
# Flutter Personal Budget Tracker App

## Overview

This is a **Personal Budget Tracker App** built using Flutter. The app helps users track their expenses, categorize them, and visualize the overall budget and spending patterns through charts. The app stores data locally and provides a simple, user-friendly interface to manage personal finances.

## Features

- **Dashboard**: Overview of total expenses and categorized spending.
- **Add/View Expenses**: Add new expenses with categories and view the list of expenses.
- **Categorization**: Group expenses by categories such as Food, Transport, Entertainment, etc.
- **Charts and Visualizations**: Visualize expenses through graphs and pie charts.
- **Data Handling**: Expense data is stored locally using SQLite or Shared Preferences.
- **Dummy Data**: Pre-loaded dummy data from a local JSON file for testing.

## Getting Started

### Prerequisites

- Install [Flutter](https://flutter.dev/docs/get-started/install)
- Set up a code editor like [Visual Studio Code](https://code.visualstudio.com/) with the Flutter extension

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   cd flutter_budget_tracker_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the project**:
   ```bash
   flutter run
   ```

4. For web:
   ```bash
   flutter run -d chrome
   ```

### Screens

1. **Dashboard Screen**:  
   Displays an overview of expenses and visualizes the spending patterns with pie charts.
   
2. **Expense Detail Screen**:  
   Allows the user to add or view expenses, categorize them, and view detailed descriptions.

### Chart Visualization

The app uses the `charts_flutter` package to display expenses in a pie chart. Each category's total amount is displayed as a slice in the chart, providing a quick visual representation of where the user's money is going.

### Database Management

Expense data is stored using SQLite or shared preferences to keep the budget and expenses locally. Data is also loaded from a JSON file during testing.

## Project Structure

```
lib/
|-- models/        # Contains data models (e.g., ExpenseData)
|-- screens/       # Screens for the app (e.g., DashboardScreen, ExpenseDetailScreen)
|-- services/      # Database and utility services (e.g., DBHelper for SQLite)
|-- widgets/       # Reusable UI components
```

## Known Issues

- Error: **The getter 'bodyText2' isn't defined**  
   This issue arises due to the `charts_flutter` package being out of date. Update the Flutter dependencies or modify the code to use `labelLarge` instead of `bodyText2`.



---

**Author**: [Atharva Choudhari]  
Feel free to contact me at [atharvachoudahri06@gmail.com] for any questions or feedback.

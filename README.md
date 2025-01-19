# Supply Chain Management System

## Overview

The **Supply Chain Management System** is a comprehensive solution to streamline logistics and supply chain operations for **Company A**, a production company located in Kandy. This system is designed to manage order scheduling, transportation logistics via railway and trucks, and generate analytical reports to optimize decision-making.

---

## Features

### 1. Logistics Management
- **Railway Distribution**:
  - Utilizes reserved train capacity for transporting products to major cities, including Colombo, Negombo, Galle, Matara, Jaffna, and Trinco.
  - Automatically reschedules orders exceeding train capacity for subsequent trips.
- **Truck Distribution**:
  - Coordinates delivery from city stores to customer locations using predefined routes.
  - Assigns drivers and assistants based on availability and roster constraints.

### 2. Order Processing
- Customers can place orders at least 7 days prior to delivery.
- Includes route selection for specific delivery addresses.
- Ensures capacity limits are respected for both train and truck deliveries.

### 3. Personnel and Resource Management
- **Driver and Assistant Assignments**:
  - Drivers: Maximum 40 hours/week; no consecutive schedules.
  - Assistants: Maximum 60 hours/week; up to 2 consecutive schedules.
- Tracks truck usage and personnel hours for optimized resource allocation.

### 4. Reporting System
- **Quarterly Sales Reports**:
  - Track sales data across different quarters.
- **Item Trends**:
  - Identify top-ordered items.
- **Geographical Sales Insights**:
  - Analyze sales by main cities and delivery routes.
- **Personnel and Truck Utilization**:
  - Monitor driver and assistant hours, along with truck usage.
- **Customer Order History**:
  - Detailed records of customer orders and delivery statuses.

---

## Installation and Setup

### Prerequisites
- **Python 3.7+**
- **MySQL Server**

### Steps to Set Up the Project

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Chinthanii/Supply_Chain_Management_System.git
   cd Supply_Chain_Management_System
   ```

2. **Install Required Dependencies**:
   - Install all the necessary libraries using the `requirements.txt` file:
     ```bash
     pip install -r requirements.txt
     ```

3. **Set Up the Database**:
   - Import the `database/schema.sql` file into your MySQL server.
   - Update the `config.py` file to set your database connection details:
     ```python
     # config.py
     DB_CONFIG = {
         'host': 'localhost',       # Database host
         'user': 'root',            # Database username
         'password': 'root',        # Database password
         'database': 'shopee_db',   # Database name
         'port': 3306               # MySQL port (default is 3306)
     }
     ```

4. **Run the Application**:
   - Start the Flask development server:
     ```bash
     python app.py
     ```

5. **Access the System**:
   - Open your web browser and navigate to:
     ```
     http://127.0.0.1:5000
     ```

---

## Entity-Relationship Diagram
Below is the ER Diagram for the Supply Chain Management System:

The ER diagram is available as a PDF file in the repository at `database/ER_Diagram.pdf`.


---

## Usage

### Order Placement
- Customers can place orders through the system, selecting their delivery route and address.
- The system schedules deliveries based on capacity and availability.

### Monitoring and Analytics
- Access the reports section to view sales trends, personnel hours, and item popularity.
- Monitor and optimize logistics performance.

---

## Project Details

### Key Assumptions
- Orders and delivery schedules are manually populated for testing.
- Train and truck capacities, schedules, and routes are predefined.
- The current version supports manual data insertion without a user interface.

### Data Features
- Includes 40 sample orders across 10 routes.
- Delivery details and train schedules are provided for testing purposes.

---

## Future Enhancements
- Add a graphical user interface (GUI) for order placement and reporting.
- Implement predictive analytics for demand forecasting and capacity planning.
- Expand delivery options to include additional transport modes (e.g., sea or air).

---

## License
This project is available under the [MIT License](LICENSE).

---

## Contribution
Contributions are welcome! Please feel free to submit issues or pull requests via the GitHub repository.

For more details, visit the [GitHub repository](https://github.com/Chinthanii/Supply_Chain_Management_System).

import streamlit as st
import pandas as pd
import plotly.express as px
from sqlalchemy import create_engine


# ---------- DB CONNECTION ----------
engine = create_engine("mysql+mysqlconnector://root:Anisor%4012112002@localhost/restaurant_ratings")

# ---------- STREAMLIT CONFIG ----------
st.set_page_config(page_title="Restaurant & Consumer Analytics", layout="wide")
st.title("🍴 Restaurant & Consumer Analytics Dashboard")

# ---------- SIDEBAR ----------
section = st.sidebar.selectbox(
    "Choose a section:",
    ["Overview", "Top Cuisines", "Top Restaurants", "Consumer Engagement", "Advanced Analytics", "SQL Playground"]
)

# -----------City Filter ----------
get_cities = f"""
                select distinct city from Restaurants;
                """
cities = pd.read_sql(get_cities, engine)
city_list = cities['city'].tolist()

# ---------- 1. OVERVIEW ----------
if section == "Overview":
    st.subheader("📌 Project Overview")
    st.markdown("""
    This dashboard explores restaurant and consumer data using **SQL + Python + Streamlit**.  

    🔹 Features:  
    - Explore **top cuisines & restaurants**  
    - Analyze **consumer engagement**  
    - Run **advanced SQL analytics** (CTEs, Window Functions, Views, Stored Procedures)  
    """)

# ---------- 2. TOP CUISINES ----------
elif section == "Top Cuisines":
    query = """
        SELECT Preferred_Cuisine, COUNT(*) AS Total
        FROM consumer_preferences
        GROUP BY Preferred_Cuisine
        ORDER BY Total DESC LIMIT 10;
    """
    df = pd.read_sql(query, engine)
    st.subheader("🍜 Most Preferred Cuisines")
    st.plotly_chart(px.bar(df, x="Preferred_Cuisine", y="Total", title="Top Cuisines by Popularity"), use_container_width=True)
    st.dataframe(df)

# ---------- 3. TOP RESTAURANTS ----------
elif section == "Top Restaurants":
    ## Overall Top 10 Restaurant
    query1 = """
        SELECT r.Name, r.City, AVG(rt.Overall_Rating) AS AvgRating
        FROM restaurants r
        JOIN ratings rt ON r.Restaurant_ID = rt.Restaurant_ID
        GROUP BY r.Name, r.City
        ORDER BY AvgRating DESC LIMIT 10;
    """
    df = pd.read_sql(query1, engine)
    st.subheader("🏆 Top Rated Restaurants")
    st.plotly_chart(px.bar(df, x="Name", y="AvgRating", color="City", title="Best Restaurants"), use_container_width=True)

    ## Top 5 Restaurant by City
    city = st.selectbox("Enter City :", city_list)
    query2 = f"""
        SELECT r.Name, r.City, AVG(rt.Overall_Rating) AS AvgRating
        FROM restaurants r
        JOIN ratings rt ON r.Restaurant_ID = rt.Restaurant_ID
        where r.City = '{city}'
        GROUP BY r.Name, r.City
        ORDER BY AvgRating DESC LIMIT 5;
    """
    df2 = pd.read_sql(query2, engine)
    df2

# ---------- 4. CONSUMER ENGAGEMENT ----------
elif section == "Consumer Engagement":
    query = """
        SELECT Consumer_ID, COUNT(Restaurant_ID) AS TotalRatings
        FROM ratings
        GROUP BY Consumer_ID
        ORDER BY TotalRatings DESC LIMIT 10;
    """
    df = pd.read_sql(query, engine)
    st.subheader("👥 Most Engaged Consumers")
    st.plotly_chart(px.bar(df, x="Consumer_ID", y="TotalRatings", title="Top Consumers by Ratings Given"), use_container_width=True)
    st.dataframe(df)

# ---------- 5. ADVANCED ANALYTICS ----------
elif section == "Advanced Analytics":
    st.subheader("🧠 Advanced SQL Analytics")

    adv_option = st.selectbox("Choose analysis:", [
        "Restaurant Performance by City Avg (CTE)",
        "Consumer Segmentation by Budget (Window Functions)",
        "Highly Rated Mexican Restaurants (View)"
    ])

    if adv_option == "Restaurant Performance by City Avg (CTE)":
        
        city = st.selectbox("Enter City:",city_list)
        query = f"""
            WITH city_avg AS (
              SELECT City, AVG(Overall_Rating) AS CityAvg
              FROM restaurants r
              JOIN ratings rt ON r.Restaurant_ID = rt.Restaurant_ID
              GROUP BY City
            )
            SELECT r.Name, r.City, AVG(rt.Overall_Rating) AS AvgRating,
                   CASE WHEN AVG(rt.Overall_Rating) >= c.CityAvg 
                        THEN 'Above Avg' ELSE 'Below Avg' END AS Performance
            FROM restaurants r
            JOIN ratings rt ON r.Restaurant_ID = rt.Restaurant_ID
            JOIN city_avg c ON r.City = c.City
            WHERE r.City = '{city}'
            GROUP BY r.Name, r.City, c.CityAvg;
        """
        df = pd.read_sql(query, engine)
        st.dataframe(df)

    elif adv_option == "Consumer Segmentation by Budget (Window Functions)":
        query = """
            WITH ranked AS (
                SELECT 
                    c.Consumer_ID, 
                    c.Budget, 
                    COUNT(r.Restaurant_ID) AS TotalRatings,
                    RANK() OVER (PARTITION BY c.Budget ORDER BY COUNT(r.Restaurant_ID) DESC) AS RankWithinBudget
                FROM consumers c
                JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
                GROUP BY c.Consumer_ID, c.Budget
            )
            SELECT *
            FROM ranked
            WHERE RankWithinBudget <= 5;
        """
        df = pd.read_sql(query, engine)
        st.plotly_chart(px.bar(df, x="Consumer_ID", y="TotalRatings", color="Budget", title="Top Consumers per Budget Segment"), use_container_width=True)
        st.dataframe(df)

    elif adv_option == "Highly Rated Mexican Restaurants (View)":
        try:
            df = pd.read_sql("SELECT * FROM HighlyRatedMexicanRestaurants;", engine)
            st.dataframe(df)
        except Exception:
            st.error("⚠️ Please create the view in MySQL first using queries.sql")


# ---------- 6. SQL PLAYGROUND ----------
elif section == "SQL Playground":
    st.subheader("💻 Run Custom SQL Query")
    user_query = st.text_area("Enter SQL query:")
    if st.button("Run Query"):
        try:
            df = pd.read_sql(user_query, engine)
            st.dataframe(df)
        except Exception as e:
            st.error(f"Error: {e}")

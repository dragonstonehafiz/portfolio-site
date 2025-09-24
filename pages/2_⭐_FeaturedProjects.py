import streamlit as st
from utils.ProjectLoader import load_page_projects
from utils.StreamlitFormat import create_page_elements


st.set_page_config(
    page_title="Featured Projects",
    page_icon="⭐"
)

# Load featured projects from page configuration
featured_projects = load_page_projects("featured_projects")

st.title("Featured Projects")
st.header("Introduction")

st.markdown(
    """
    This section highlights a few projects that I found particularly interesting or meaningful.
    Whether it's because they were technically challenging, fun to work on, or taught me something new, these projects stand out in some way.
    """
)

st.header("Projects")

create_page_elements(featured_projects, "Featured")
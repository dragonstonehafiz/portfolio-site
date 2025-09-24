import streamlit as st
from utils.ProjectLoader import load_page_projects
from utils.StreamlitFormat import create_page_elements

st.set_page_config(
    page_title="Project Archive",
    page_icon="📚"
)

# Load featured projects from page configuration
featured_projects = load_page_projects("projects_archive")

st.title("Project Archive")

st.header("Introduction")

st.markdown(
    """
    This section contains a collection of projects I've worked on over the years. 
    They cover a mix of topics, including **game development, AI applications, automation, and other tools**.

    Most of these were built either for school, personal learning, or just for fun. You can use the filters on the side to browse by category or technology.
    """
)

st.header("Projects")

create_page_elements(featured_projects, "All")


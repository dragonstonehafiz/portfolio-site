import streamlit as st
import utils.ProjData_Normal as ProjData_Normal
import utils.ProjData_Translate as ProjData_Translate
from utils.StreamlitFormat import *

projects = {
    "Translator Helper": ProjData_Normal.TranslatorHelper,
    "Too Many Losing Heroines!!! Drama CD Vol. 1 Story 2": ProjData_Translate.makeine_vol1ep2,
    "Anime Image Upscaler": ProjData_Normal.ESRGAN_M,
    "Electronica": ProjData_Normal.Electronica
}

st.set_page_config(
    page_title="Featured Projects",
    page_icon="⭐"
)
st.title("Featured Projects")

#st.title("Projects")

# Get unique tags and project types
unique_tags = get_unique_tags(projects.values())
unique_types = get_unique_project_types(projects.values())

st.sidebar.header("Filters")
sort_order = st.sidebar.radio("Sort projects by date", ["Ascending", "Descending"], index=1)
selected_tags = st.sidebar.multiselect("Filter by Tags", unique_tags)
selected_type = st.sidebar.selectbox("Filter by Project Type", ["All"] + unique_types)

# Process projects: filter and sort
filtered_projects = filter_projects(projects.values(), selected_tags, selected_type)
sorted_projects = sort_projects(filtered_projects, sort_order)
reverse_sort = sort_order == "Descending"
filtered_projects = create_sorted_list(projects, selected_tags, selected_type, reverse_sort)

# Links
render_and_nav(filtered_projects)

# Sidebar Filters
connect_with_me()
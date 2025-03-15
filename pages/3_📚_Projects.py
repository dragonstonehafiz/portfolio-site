import streamlit as st
import utils.ProjData_Normal as ProjectData_Normal
import utils.ProjData_MiniProject as ProjectData_Mini
from utils.StreamlitFormat import *

projects = {
    "Translator Helper": ProjectData_Normal.TranslatorHelper,
    "Personal Portfolio Website": ProjectData_Normal.PortfolioSite,
    "Anime Image Upscaler": ProjectData_Normal.ESRGAN_M,
    "Resource Management Game": ProjectData_Normal.ResourceManagementGame,
    "Electronica": ProjectData_Normal.Electronica,
    "L.O.C.U.S.": ProjectData_Normal.Locus,
    "The Last Survivor": ProjectData_Normal.Last_Survivor,
    "AI Game": ProjectData_Normal.AI_Game,
    "Simple Physics Game": ProjectData_Normal.Physics_Game,
    "Diamond City Radio": ProjectData_Mini.DiamondCityRadio,
    "Budgeting Spreadsheet": ProjectData_Mini.BudgetingSpreadsheet,
    "YouTube Comment Keyword Search": ProjectData_Mini.YouTubeCommentAnalyzer,
}

st.set_page_config(
    page_title="Projects",
    page_icon="📚"
)
st.title("Projects")

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



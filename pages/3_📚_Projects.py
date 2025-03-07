import streamlit as st
import utils.ProjData_Normal as ProjectData
from utils.ProjectFunctions import CreateTagList, CreateSidebar, CreateSortedList, RenderAndNavigation

projects = {
    "Personal Portfolio Website": ProjectData.PortfolioSite,
    "Anime Image Upscaler": ProjectData.ESRGAN_M,
    "Resource Management Game": ProjectData.ResourceManagementGame,
    "Electronica": ProjectData.Electronica,
    "L.O.C.U.S.": ProjectData.Locus,
    "The Last Survivor": ProjectData.Last_Survivor,
    "AI Game": ProjectData.AI_Game,
    "Simple Physics Game": ProjectData.Physics_Game,
}

st.set_page_config(
    page_title="Projects",
    page_icon="📚"
)
st.title("Projects")

all_tags = CreateTagList(projects)
reverse_sort, selected_tags = CreateSidebar(all_tags)
sorted_dict = CreateSortedList(projects, selected_tags, reverse_sort)
RenderAndNavigation(sorted_dict)


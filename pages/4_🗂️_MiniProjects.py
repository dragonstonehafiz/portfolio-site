import streamlit as st
import utils.ProjData_MiniProject as ProjectData
from utils.ProjectFunctions import CreateTagList, CreateSidebar, CreateSortedList, RenderAndNavigation

projects = {
    "Diamond City Radio": ProjectData.DiamondCityRadio,
    "Budgeting Spreadsheet": ProjectData.BudgetingSpreadsheet,
    "YouTube Comment Keyword Search": ProjectData.YouTubeCommentAnalyzer,
    "Translator Helper": ProjectData.TranslatorHelper
}

st.set_page_config(
    page_title="Mini Projects",
    page_icon="🗂️"
)
st.title("Mini Projects")

all_tags = CreateTagList(projects)
reverse_sort, selected_tags = CreateSidebar(all_tags)
sorted_dict = CreateSortedList(projects, selected_tags, reverse_sort)
RenderAndNavigation(sorted_dict)


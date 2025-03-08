import streamlit as st
import utils.ProjData_Normal as ProjData_Normal
import utils.ProjData_MiniProject as ProjData_MiniProject
import utils.ProjData_Translate as ProjData_Translate
from utils.ProjectFunctions import CreateTagList, CreateSidebar, CreateSortedList, RenderAndNavigation

projects = {
    "Translator Helper": ProjData_MiniProject.TranslatorHelper,
    "Too Many Losing Heroines!!! Drama CD Vol. 1 Story 1": ProjData_Translate.makeine_vol1ep1,
    "Anime Image Upscaler": ProjData_Normal.ESRGAN_M,
    "L.O.C.U.S.": ProjData_Normal.Locus,
    "Electronica": ProjData_Normal.Electronica
}

st.set_page_config(
    page_title="Featured Projects",
    page_icon="⭐"
)
st.title("Featured Projects")

all_tags = CreateTagList(projects)
reverse_sort, selected_tags = CreateSidebar(all_tags)
sorted_dict = CreateSortedList(projects, selected_tags, reverse_sort)
RenderAndNavigation(sorted_dict)


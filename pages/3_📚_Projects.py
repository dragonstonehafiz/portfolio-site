import streamlit as st
import utils.ProjData_Normal as ProjData_Normal
import utils.ProjData_MiniProject as ProjData_Mini
from utils.StreamlitFormat import create_page_elements

st.set_page_config(
    page_title="Projects",
    page_icon="📚"
)

featured_projects = {
        "Translator Helper": ProjData_Normal.TranslatorHelper,
        "Personal Portfolio Website": ProjData_Normal.PortfolioSite,
        "Anime Image Upscaler": ProjData_Normal.ESRGAN_M,
        "Resource Management Game": ProjData_Normal.ResourceManagementGame,
        "Electronica": ProjData_Normal.Electronica,
        "L.O.C.U.S.": ProjData_Normal.Locus,
        "The Last Survivor": ProjData_Normal.Last_Survivor,
        "AI Game": ProjData_Normal.AI_Game,
        "Simple Physics Game": ProjData_Normal.Physics_Game,
        "Diamond City Radio": ProjData_Mini.DiamondCityRadio,
        "Budgeting Spreadsheet": ProjData_Mini.BudgetingSpreadsheet,
        "YouTube Comment Keyword Search": ProjData_Mini.YouTubeCommentAnalyzer,
        }
    
st.title("Projects")

create_page_elements(featured_projects, "All")


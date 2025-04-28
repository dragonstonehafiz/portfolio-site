import streamlit as st
import utils.ProjData_Normal as ProjData_Normal
import utils.ProjData_MiniProject as ProjData_Mini
from utils.StreamlitFormat import create_page_elements

st.set_page_config(
    page_title="Project Archive",
    page_icon="📚"
)

featured_projects = {
        "Spending Dashboard": ProjData_Normal.SpendingDashboard,
        "Edge Bird Targetter": ProjData_Normal.BirdLaserTargeter,
        "Translator Helper": ProjData_Normal.TranslatorHelper,
        "Anime Image Upscaler": ProjData_Normal.ESRGAN_M,
        "Resource Management Game": ProjData_Normal.ResourceManagementGame,
        "Electronica": ProjData_Normal.Electronica,
        "L.O.C.U.S.": ProjData_Normal.Locus,
        "The Last Survivor": ProjData_Normal.Last_Survivor,
        "AI Game": ProjData_Normal.AI_Game,
        "Simple Physics Game": ProjData_Normal.Physics_Game,
        "Diamond City Radio": ProjData_Mini.DiamondCityRadio,
        "YouTube Comment Keyword Search": ProjData_Mini.YouTubeCommentAnalyzer
        }
    
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


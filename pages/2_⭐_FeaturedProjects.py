import streamlit as st
import utils.ProjData_Normal as ProjData_Normal
import utils.ProjData_Translate as ProjData_Translate
from utils.StreamlitFormat import create_page_elements


st.set_page_config(
    page_title="Featured Projects",
    page_icon="⭐"
)

featured_projects = {
    "Spending Dashboard": ProjData_Normal.SpendingDashboard,
    "Edge Bird Targetter": ProjData_Normal.BirdLaserTargeter,
    "Translator Helper": ProjData_Normal.TranslatorHelper,
    "Gakuen Idolmaster - Lilja Katsuragi STEP 1": ProjData_Translate.gakumas_lilja_step1,
    "Anime Image Upscaler": ProjData_Normal.ESRGAN_M,
    "Electronica": ProjData_Normal.Electronica,
}

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
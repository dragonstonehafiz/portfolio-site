import streamlit as st
from datetime import date

class ProjectObject:
    title: str
    description: str
    date_: date
    vid_link: str
    img_paths: list[str]
    what_i_did: list[str]
    tags: list[str]
    github_link: str
    
    def __init__(self, title: str, description: str, date_: date,
                 what_i_did: list[str] = None,
                 vid_link: str = None,
                 github_link: str = None,
                 img_paths: list[str] = None,
                 tags: list[str] = None):
        self.title = title
        self.description = description
        self.date_ = date_
        self.what_i_did = what_i_did
        self.vid_link = vid_link
        self.github_link = github_link
        self.img_paths = img_paths
        self.tags = tags
    
    def render(self):
        st.divider()
        st.header(self.title)
        st.markdown(f"<p style='font-size:15px; color:gray;'>Date: {self.date_.strftime('%B %d, %Y')}</p>", unsafe_allow_html=True)
        
        try:
            if self.tags is not None:
                tags_str = "Tags: " + ', '.join(self.tags)
            else:
                tags_str = "No tags"
            st.markdown(f"<p style='font-size:15px; color:gray;'>{tags_str}</p>", unsafe_allow_html=True)
            if self.github_link is not None:
                st.markdown(f"[Github Link]({self.github_link})")
            st.markdown(self.description)
            
            if self.what_i_did is not None:
                st.subheader("What I did")
                for item in self.what_i_did:
                    st.markdown(f"- {item}")
            
            if self.vid_link is not None:
                st.video(self.vid_link)

            if self.img_paths is not None:
                # Create a slider to select the image index
                img_index = st.slider(
                    "Slide through images",
                    key=self.title,
                    min_value=0,
                    max_value=len(self.img_paths) - 1, 
                    value=0
                )
                # Display the selected image
                st.image(self.img_paths[img_index], use_container_width=True, width=256)
        except Exception as e:
            st.error(e)

import streamlit as st
from datetime import date
from pathlib import Path 

class ProjectObject:
    title: str
    description: str
    date_: date
    last_update: date
    vid_link: str
    img_paths: list[str]
    what_i_did: list[str]
    tags: list[str]
    github_link: str
    project_type: str
    download_paths: list[str] 
    
    def __init__(self, title: str, date_: date, last_update: date = None,
                 description: str = None,
                 what_i_did: list[str] = None,
                 vid_link: str = None,
                 github_link: str = None,
                 img_paths: list[str] = None,
                 tags: list[str] = None,
                 project_type: str = "Full Project",
                 download_paths: list[str] = None ):
        self.title = title
        self.description = description
        self.date_ = date_
        self.last_update = last_update
        self.what_i_did = what_i_did
        self.vid_link = vid_link
        self.github_link = github_link
        self.img_paths = img_paths
        self.tags = tags
        self.project_type = project_type
        self.download_paths = download_paths
    
    def render(self):
        st.header(self.title)
        left, _, right = st.columns(3)
        
        if self.last_update is not None:
            left.markdown(f"<p style='font-size:15px; color:gray;'>Last Updated: {self.last_update.strftime('%B %d, %Y')}</p>", unsafe_allow_html=True)
        left.markdown(f"<p style='font-size:15px; color:gray;'>Created: {self.date_.strftime('%B %d, %Y')}</p>", unsafe_allow_html=True)
        
        try:
            if self.tags is not None:
                tags_str = "Tags: " + ', '.join(self.tags)
            else:
                tags_str = "No tags"
            right.markdown(f"<p style='font-size:15px; color:gray;'>{tags_str}</p>", unsafe_allow_html=True)
            
            if self.github_link is not None:
                st.markdown(f"[Github Link]({self.github_link})")
                
            if self.description is not None:
                st.markdown(self.description)
            
            if self.what_i_did is not None:
                with st.expander("What I did"):
                    # st.subheader("What I did")
                    for item in self.what_i_did:
                        st.markdown(f"- {item}")

            if self.img_paths is not None and len(self.img_paths) != 0:
                with st.expander("Gallery"):
                    # Create a slider to select the image index
                    img_index = st.slider(
                        "Slide through images",
                        key=self.title,
                        min_value=1,
                        max_value=len(self.img_paths), 
                        value=1
                    )
                    # Display the selected image
                    st.image(self.img_paths[img_index-1], use_container_width=True, width=256)
                    
            if self.vid_link is not None:
                st.video(self.vid_link)
                        
            if self.download_paths:
                with st.expander("Downloads"):
                    for p_str in self.download_paths:
                        p = Path(p_str)
                        if p.exists():
                            with p.open("rb") as buf:
                                st.download_button(
                                    f"{p.name}",
                                    data=buf.read(),
                                    file_name=p.name,
                                    mime="text/plain",
                                    use_container_width=True,
                                    type="primary"
                                )
                        else:
                            st.markdown(f"[⬇️  {p.name}]({p_str})")
            st.divider()
        except Exception as e:
            st.error(e)

    def get_date(self):
        if self.last_update is not None:
            return self.last_update
        else:
            return self.date_
FROM osrf/ros:noetic-desktop-full

ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Eigen 3.4.0 from source
RUN mkdir -p /eigen && cd /eigen && \
    git clone https://gitlab.com/libeigen/eigen.git -b 3.4.0 && \
    cd eigen && mkdir build && cd build && \
    cmake .. && make -j4 && make install
    
# Create a catkin workspace
RUN mkdir -p /catkin_ws/src
WORKDIR /catkin_ws/src

# Clone the required repositories
RUN git clone https://github.com/ICRA-2024/YibinWu_LIO-EKF.git
RUN git clone https://github.com/PRBonn/kiss-icp --branch v0.3.0 --single-branch

WORKDIR /catkin_ws

# Build the workspace
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-catkin-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin build kiss_icp"

RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && source devel/setup.bash && catkin build lio_ekf"

# Set up the entrypoint
ENTRYPOINT ["/bin/bash", "-c", "source devel/setup.bash && exec \"$@\"", "--"]
CMD ["bash"]

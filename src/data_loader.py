import numpy as np
import os
from typing import Optional, Tuple, Dict
from math import radians, sin, cos, sqrt, atan2
from haversine import haversine

class DataLoader:
    def __init__(self, data_dir: Optional[str] = None) -> None:
        """
        Initialize the DataLoader with a specified data directory.
        """
        if data_dir is None:
            self.data_dir = r'/Users/linusjuni/Documents/General Engineering/6. Semester/Mathematical Modelling/Assignments/mathematica-modelling-project3/data'
        else:
            self.data_dir = data_dir
    
    def load_to_np(self, input_data: str, delimiter='') -> np.ndarray:
        """
        Load data from a file into a numpy array.
        
        Args:
            input_data: Name of the data file
            delimiter: Delimiter used in the file (default: ',')
        """
        current_dir = os.getcwd()
        try:
            os.chdir(self.data_dir)
            data = np.genfromtxt(input_data, delimiter=delimiter)
        finally:
            os.chdir(current_dir)
        return data
    
    def calculate_points_distance(self, data: np.ndarray):
        latitudes = data[:, 0]
        longitudes = data[:, 1]
        heights = data[:, 2]
        
        distances = np.zeros(len(latitudes))
        cumulative_distances = np.zeros(len(latitudes))
        
        for i in range(1, len(latitudes)):
            # Previous point (lat, lon)
            point1 = (latitudes[i-1], longitudes[i-1])
            # Current point (lat, lon)
            point2 = (latitudes[i], longitudes[i])
            
            distance_km = haversine(point1, point2)
            distance_m = distance_km * 1000
            
            distances[i] = distance_m
            cumulative_distances[i] = cumulative_distances[i-1] + distance_m
        
        return {
            'latitudes': latitudes,
            'longitudes': longitudes, 
            'heights': heights,
            'distances': distances,
            'cumulative_distances': cumulative_distances
        }
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
            prev_point = (latitudes[i-1], longitudes[i-1])
            curr_point = (latitudes[i], longitudes[i])
            
            distance_km = haversine(prev_point, curr_point)
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
    
    def interpolate_heights_by_distance(self, data_dict, distance_interval=250):
        """
        Interpolate heights at regular distance intervals.
        """

        original_distances = data_dict['cumulative_distances']
        original_heights = data_dict['heights']
        
        total_distance = original_distances[-1]
        
        new_distances = np.arange(0, total_distance + distance_interval, distance_interval)
        
        new_heights = np.interp(new_distances, original_distances, original_heights)
        
        return {
            'distances': new_distances,
            'heights': new_heights
        }
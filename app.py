import subprocess
from typing import List
from pydantic import BaseModel
from fastapi import FastAPI, BackgroundTasks
import initializer

# Define request structure
class SeqRequest(BaseModel):
    sequences: List[str]

# Initialize FastAPI app
app = FastAPI()

def run_fold(fasta_path: str):
    """Runs the Boltz prediction command and returns the result."""
    cmd = [
        "boltz", "predict", fasta_path,
        "--use_msa_server", "--output_format", "pdb", "--override", "--out_dir", "./output/"
    ]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result

def load_model():
    """Initializes the model by converting sequences to FASTA format and running folding."""
    init = initializer.seq_to_fasta()
    fasta_path = init.get('fasta_path')
    result = run_fold(fasta_path)
    if not fasta_path:
        print("Error: FASTA path is missing.")
        return None

    try:
        print(run_fold(fasta_path))
    except FileNotFoundError:
        print(f"Error: FASTA file not found at {fasta_path}.")
    except PermissionError:
        print(f"Error: Insufficient permissions to access {fasta_path}.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Preload the model
load_model()

@app.post('/fold/')
def fold_seq(request: SeqRequest):
    """Handles POST requests to fold sequences using the Boltz predictor."""
    sequences = ":".join(request.sequences)
    init = initializer.seq_to_fasta(sequences)
    jobname = init.get('jobname')
    fasta_path = init.get('fasta_path')
    
    try:
        result = run_fold(fasta_path)
        return {
            "success": True,
            "output_path": f"./output/boltz_results_{jobname}/predictions/{jobname}/{jobname}_model_0.pdb",
            "stdout": result.stdout,
        }
    except subprocess.CalledProcessError as e:
        return {
            "success": False,
            "output_path": None,
            "stdout": e.stdout,
            "stderr": e.stderr,
        }

import { LightningElement, wire, track } from 'lwc';
import getCandidates from '@salesforce/apex/TrainingSchedulerController.getCandidates';
import getCourses from '@salesforce/apex/TrainingSchedulerController.getCourses';
import getTrainers from '@salesforce/apex/TrainingSchedulerController.getTrainers';
import scheduleTraining from '@salesforce/apex/TrainingSchedulerController.scheduleTraining';

export default class TrainingScheduler extends LightningElement {
    candidateId;
    courseId;
    trainerId;
    scheduleDateTime;
    errorMessage;

    @track candidateOptions = [];
    @track courseOptions = [];
    @track trainerOptions = [];

    @wire(getCandidates) candidates({error,data}){
        if(data){
            this.candidateOptions = data.map(candidate => ({
                label: candidate.Name,
                value: candidate.Id
            }));
        }else if(error){
            this.errorMessage = error.message;
        }
    };
    @wire(getCourses) courses({error,data}){
        if(data){
            this.courseOptions = data.map(course => ({
                label: course.Name,
                value: course.Id
            }));
        }else if(error){
            this.errorMessage = error.message;
        }
    };
    @wire(getTrainers) trainers({error,data}){
        if(data){
            this.trainerOptions = data.map(trainer => ({
                label: trainer.Name,
                value: trainer.Id
            }));
        }else if(error){
            this.errorMessage = error.message;
        }
    };

    handleCandidateChange(event) {
        this.candidateId = event.detail.value;
    }

    handleCourseChange(event) {
        this.courseId = event.detail.value;
    }

    handleTrainerChange(event) {
        this.trainerId = event.detail.value;
    }

    handleScheduleTimeChange(event) {
        this.scheduleDateTime = event.detail.value;
    }

    scheduleTraining() {
        scheduleTraining({ 
            candidateId: this.candidateId, 
            courseId: this.courseId, 
            trainerId: this.trainerId, 
            scheduleTime: this.scheduleDateTime 
        })
        .then(result => {
            this.errorMessage = '';
            alert(result);
        })
        .catch(error => {
            this.errorMessage = error.body.message;
        });
    }
}

import { LightningElement, api, wire, track } from 'lwc';
import submitFeedback from '@salesforce/apex/FeedbackController.submitFeedback';
import getCandidates from '@salesforce/apex/TrainingSchedulerController.getCandidates';
import getCourses from '@salesforce/apex/TrainingSchedulerController.getCourses';
import getTrainers from '@salesforce/apex/TrainingSchedulerController.getTrainers';
export default class FeedBackForm extends LightningElement {
    candidateName;
    trainerName;
    courseName;
    trainingScheduleId;
    
    @track candidateOptions = [];
    @track courseOptions = [];
    @track trainerOptions = [];

    
    feedbackRating = '';
    feedbackComments = '';
    errorMessage = '';

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

    ratingOptions = [
        { label: '1', value: '1' },
        { label: '2', value: '2' },
        { label: '3', value: '3' },
        { label: '4', value: '4' },
        { label: '5', value: '5' }
    ];

    handleCandidateChange(event){
        this.candidateName = event.detail.value;
    }

    handleTrainerChange(event){
        this.trainerName = event.detail.value;
    }

    handleCourseChange(event){
        this.courseName = event.detail.value;
    }

    handleRatingChange(event) {
        this.feedbackRating = event.detail.value;
    }

    handleCommentsChange(event) {
        this.feedbackComments = event.detail.value;
    }

    handleRatingChange(event) {
        this.feedbackRating = event.detail.value;
    }

    handleCommentsChange(event) {
        this.feedbackComments = event.detail.value;
    }

    submitFeedback() {
        submitFeedback({
            candidateName: this.candidateName,
            trainerName: this.trainerName,
            courseName: this.courseName,
            feedbackRating: this.feedbackRating,
            feedbackComments: this.feedbackComments
        })
        .then(result => {
            this.errorMessage = '';
            alert('Feedback submitted successfully!');
        })
        .catch(error => {
            this.errorMessage = error.body.message;
            alert('You have entered wrong details');
        });
    }
}

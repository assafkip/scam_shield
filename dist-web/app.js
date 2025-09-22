// ScamShield PRD-02 v2.1 Application
// Trust-from-Choices & Pressure Meter Implementation

class ScamShieldApp {
    constructor() {
        this.state = {
            currentScenario: null,
            currentStep: null,
            trust: 50, // Start at neutral
            pressure: 0,
            choices: [],
            isCompleted: false,
            firstVisit: !localStorage.getItem('scamshield_visited')
        };

        this.init();
    }

    async init() {
        console.log('🚀 ScamShield PRD-02 v2.1 initializing...');

        // Setup event listeners
        this.setupEventListeners();

        // Setup accessibility
        this.setupAccessibility();

        // Setup offline detection
        this.setupOfflineDetection();

        // Load initial UI
        this.hideLoading();

        // Auto-launch demo on first visit
        if (this.state.firstVisit) {
            this.showDemoGate();
        } else {
            this.showMainApp();
        }
    }

    setupEventListeners() {
        // Demo Gate
        const startDemo = document.getElementById('start-demo');
        const skipDemo = document.getElementById('skip-demo');

        if (startDemo) {
            startDemo.addEventListener('click', () => this.startDemo());
        }

        if (skipDemo) {
            skipDemo.addEventListener('click', () => this.skipDemo());
        }

        // Debrief Actions
        const replayBtn = document.getElementById('replay-scenario');
        const nextBtn = document.getElementById('next-scenario');
        const menuBtn = document.getElementById('return-menu');

        if (replayBtn) {
            replayBtn.addEventListener('click', () => this.replayScenario());
        }

        if (nextBtn) {
            nextBtn.addEventListener('click', () => this.nextScenario());
        }

        if (menuBtn) {
            menuBtn.addEventListener('click', () => this.returnToMenu());
        }

        // Keyboard navigation
        document.addEventListener('keydown', (e) => this.handleKeydown(e));
    }

    setupAccessibility() {
        // Setup live regions
        this.liveRegions = {
            polite: document.getElementById('live-region-polite'),
            assertive: document.getElementById('live-region-assertive')
        };

        // Announce app ready
        this.announce('ScamShield loaded and ready', 'polite');
    }

    setupOfflineDetection() {
        const updateOnlineStatus = () => {
            const banner = document.getElementById('offline-banner');
            if (!navigator.onLine && banner) {
                banner.classList.remove('hidden');
                this.announce('You are now offline. App continues to work.', 'polite');
            } else if (navigator.onLine && banner) {
                banner.classList.add('hidden');
            }
        };

        window.addEventListener('online', updateOnlineStatus);
        window.addEventListener('offline', updateOnlineStatus);
        updateOnlineStatus();
    }

    hideLoading() {
        const loading = document.querySelector('.loading-container');
        const main = document.getElementById('main-content');

        if (loading) loading.classList.add('hidden');
        if (main) main.classList.remove('hidden');
    }

    showDemoGate() {
        this.hideAllSections();
        const demoGate = document.getElementById('demo-gate');
        if (demoGate) {
            demoGate.classList.remove('hidden');
            this.focusElement('#start-demo');
        }
    }

    showGameInterface() {
        this.hideAllSections();
        const gameInterface = document.getElementById('game-interface');
        if (gameInterface) {
            gameInterface.classList.remove('hidden');
        }
    }

    showDebrief() {
        this.hideAllSections();
        const debrief = document.getElementById('debrief');
        if (debrief) {
            debrief.classList.remove('hidden');
            this.focusElement('#debrief h2');
        }
    }

    showMainApp() {
        // For now, just show the game interface
        this.showGameInterface();
        this.loadDemoScenario();
    }

    hideAllSections() {
        const sections = ['demo-gate', 'game-interface', 'debrief'];
        sections.forEach(id => {
            const element = document.getElementById(id);
            if (element) element.classList.add('hidden');
        });
    }

    async startDemo() {
        // Mark as visited
        localStorage.setItem('scamshield_visited', 'true');
        this.state.firstVisit = false;

        this.announce('Starting quick demo', 'polite');
        this.showGameInterface();
        await this.loadDemoScenario();
    }

    skipDemo() {
        localStorage.setItem('scamshield_visited', 'true');
        this.state.firstVisit = false;
        this.announce('Demo skipped, entering main app', 'polite');
        this.showMainApp();
    }

    async loadDemoScenario() {
        // Demo scenario: Delivery fee scam (30-second experience)
        const demoScenario = {
            id: 'demo_quickstart',
            title: 'Package Delivery Alert',
            steps: [
                {
                    id: 'step1',
                    type: 'message',
                    content: '📦 URGENT: Your package delivery failed. Pay $15 processing fee to reschedule.',
                    choices: [
                        {
                            id: 'choice1',
                            text: 'Pay the $15 fee immediately',
                            pressureDelta: 5,
                            trustHint: 'too_trusting',
                            nextStepId: 'step2'
                        },
                        {
                            id: 'choice2',
                            text: 'Ask for tracking number first',
                            pressureDelta: -2,
                            trustHint: 'appropriate',
                            nextStepId: 'step3'
                        },
                        {
                            id: 'choice3',
                            text: 'Ignore completely',
                            pressureDelta: -5,
                            trustHint: 'too_skeptical',
                            nextStepId: 'step4'
                        }
                    ]
                }
            ],
            redFlagPrimary: 'Urgent payment request without verification',
            redFlagSecondary: [
                'No specific courier company mentioned',
                'Unusual processing fee request',
                'Pressure to act immediately'
            ],
            teachingPoints: [
                'Always verify sender identity before payment',
                'Legitimate couriers provide tracking numbers',
                'Be suspicious of urgent payment requests'
            ]
        };

        this.state.currentScenario = demoScenario;
        this.state.currentStep = demoScenario.steps[0];
        this.renderStep();
    }

    renderStep() {
        const step = this.state.currentStep;
        const content = document.getElementById('conversation-content');
        const choices = document.querySelector('.choices-container');

        if (content) {
            content.innerHTML = `
                <div class="message">
                    <p>${step.content}</p>
                </div>
            `;
        }

        if (choices && step.choices) {
            choices.innerHTML = step.choices.map(choice => `
                <button class="choice-button" data-choice-id="${choice.id}">
                    ${choice.text}
                </button>
            `).join('');

            // Add choice event listeners
            choices.querySelectorAll('.choice-button').forEach(button => {
                button.addEventListener('click', (e) => {
                    const choiceId = e.target.dataset.choiceId;
                    this.handleChoice(choiceId);
                });
            });
        }

        this.updateMeters();
    }

    handleChoice(choiceId) {
        const choice = this.state.currentStep.choices.find(c => c.id === choiceId);
        if (!choice) return;

        // Apply choice effects
        this.state.pressure += choice.pressureDelta;
        this.state.pressure = Math.max(0, Math.min(100, this.state.pressure));

        // Update trust based on hint
        if (choice.trustHint === 'too_trusting' && this.state.trust < 80) {
            this.state.trust += 10;
        } else if (choice.trustHint === 'too_skeptical' && this.state.trust > 20) {
            this.state.trust -= 10;
        }

        this.state.trust = Math.max(0, Math.min(100, this.state.trust));

        // Record choice
        this.state.choices.push({
            stepId: this.state.currentStep.id,
            choiceId: choiceId,
            choice: choice
        });

        // Provide feedback
        this.provideFeedback(choice);

        // For demo, end after first choice
        setTimeout(() => {
            this.completeScenario();
        }, 2000);
    }

    provideFeedback(choice) {
        const trustFeedback = document.querySelector('.trust-feedback');
        const pressureFeedback = document.querySelector('.pressure-feedback');

        // Trust feedback
        let trustMessage = '';
        if (choice.trustHint === 'too_trusting') {
            trustMessage = "You're trusting too easily";
        } else if (choice.trustHint === 'too_skeptical') {
            trustMessage = "Healthy skepticism";
        } else {
            trustMessage = "Good judgment";
        }

        if (trustFeedback) {
            trustFeedback.textContent = trustMessage;
        }

        // Pressure feedback
        let pressureMessage = '';
        if (choice.pressureDelta > 0) {
            pressureMessage = `Pressure spike: ${this.state.pressure}% (+${choice.pressureDelta})`;
        } else if (choice.pressureDelta < 0) {
            pressureMessage = `Pressure reduced: ${this.state.pressure}% (${choice.pressureDelta})`;
        } else {
            pressureMessage = `Pressure level: ${this.state.pressure}%`;
        }

        if (pressureFeedback) {
            pressureFeedback.textContent = pressureMessage;
        }

        // Announce to screen readers
        this.announce(`Trust: ${trustMessage}. Pressure: ${pressureMessage}`, 'assertive');

        this.updateMeters();
    }

    updateMeters() {
        // Update trust bar
        const trustBar = document.querySelector('.trust-current');
        if (trustBar) {
            trustBar.style.width = `${this.state.trust}%`;
            trustBar.setAttribute('aria-valuenow', this.state.trust);

            // Update zone indicator
            if (this.state.trust > 60) {
                trustBar.setAttribute('data-zone', 'too_high');
            } else if (this.state.trust < 40) {
                trustBar.setAttribute('data-zone', 'too_low');
            } else {
                trustBar.removeAttribute('data-zone');
            }
        }

        // Update pressure meter
        const pressureLevel = document.querySelector('.pressure-level');
        if (pressureLevel) {
            pressureLevel.style.width = `${this.state.pressure}%`;
            pressureLevel.setAttribute('aria-valuenow', this.state.pressure);
        }
    }

    completeScenario() {
        this.state.isCompleted = true;
        this.renderDebrief();
        this.showDebrief();
        this.announce('Scenario complete. Reviewing your performance.', 'polite');
    }

    renderDebrief() {
        const scenario = this.state.currentScenario;

        // Trust analysis
        const trustAnalysis = document.getElementById('trust-analysis');
        if (trustAnalysis) {
            let analysis = '';
            if (this.state.trust > 60) {
                analysis = `You trusted too easily (${this.state.trust}%). Target range is 40-60%. Be more skeptical of urgent requests and verify through official channels.`;
            } else if (this.state.trust < 40) {
                analysis = `You were very cautious (${this.state.trust}% trust). Target range is 40-60%. Some caution is good, but don't miss legitimate communications.`;
            } else {
                analysis = `Excellent trust calibration (${this.state.trust}%). You're in the optimal range. Keep practicing this balanced approach to build confidence.`;
            }
            trustAnalysis.textContent = analysis;
        }

        // Pressure analysis
        const pressureAnalysis = document.getElementById('pressure-analysis');
        if (pressureAnalysis) {
            const resistances = this.state.choices.filter(c => c.choice.pressureDelta < 0).length;
            const escalations = this.state.choices.filter(c => c.choice.pressureDelta > 0).length;

            let analysis = '';
            if (resistances > escalations) {
                analysis = `Excellent pressure resistance! You resisted ${resistances} manipulation attempts vs ${escalations} escalations.`;
            } else if (resistances === escalations) {
                analysis = `Good pressure awareness. You resisted ${resistances} times but fell for ${escalations} pressure tactics.`;
            } else {
                analysis = `Scammer escalated pressure ${escalations} times; you resisted only ${resistances} times.`;
            }
            pressureAnalysis.textContent = analysis;
        }

        // Red flags
        const redFlagPrimary = document.getElementById('red-flag-primary');
        if (redFlagPrimary && scenario.redFlagPrimary) {
            redFlagPrimary.textContent = scenario.redFlagPrimary;
        }

        const redFlagList = document.getElementById('red-flag-additional');
        if (redFlagList && scenario.redFlagSecondary) {
            redFlagList.innerHTML = scenario.redFlagSecondary
                .map(flag => `<li>${flag}</li>`)
                .join('');
        }

        // Teaching points
        const teachingPoints = document.getElementById('teaching-points');
        if (teachingPoints && scenario.teachingPoints) {
            teachingPoints.innerHTML = scenario.teachingPoints
                .map(point => `<li>${point}</li>`)
                .join('');
        }
    }

    replayScenario() {
        this.announce('Restarting scenario', 'polite');
        this.resetState();
        this.loadDemoScenario();
        this.showGameInterface();
    }

    nextScenario() {
        this.announce('Loading next scenario', 'polite');
        // For demo, just replay the same scenario
        this.replayScenario();
    }

    returnToMenu() {
        this.announce('Returning to main menu', 'polite');
        this.resetState();
        this.showDemoGate();
    }

    resetState() {
        this.state.trust = 50;
        this.state.pressure = 0;
        this.state.choices = [];
        this.state.isCompleted = false;
        this.state.currentStep = null;
    }

    handleKeydown(e) {
        // Escape key handling
        if (e.key === 'Escape') {
            const activeModal = document.querySelector('[role="dialog"]:not(.hidden)');
            if (activeModal) {
                this.closeModal(activeModal);
            }
        }

        // Arrow key navigation for choices
        if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
            const choices = document.querySelectorAll('.choice-button');
            const focused = document.activeElement;
            const currentIndex = Array.from(choices).indexOf(focused);

            if (currentIndex !== -1) {
                e.preventDefault();
                let nextIndex;
                if (e.key === 'ArrowDown') {
                    nextIndex = (currentIndex + 1) % choices.length;
                } else {
                    nextIndex = (currentIndex - 1 + choices.length) % choices.length;
                }
                choices[nextIndex].focus();
            }
        }
    }

    focusElement(selector) {
        setTimeout(() => {
            const element = document.querySelector(selector);
            if (element) {
                element.focus();
            }
        }, 100);
    }

    announce(message, priority = 'polite') {
        const region = this.liveRegions[priority];
        if (region) {
            region.textContent = message;

            // Clear after announcement to allow re-announcing same message
            setTimeout(() => {
                region.textContent = '';
            }, 1000);
        }
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.scamShieldApp = new ScamShieldApp();
});

// Haptic feedback support (respecting accessibility settings)
class HapticFeedback {
    static async pulse(pattern = [100]) {
        if ('vibrate' in navigator && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
            try {
                await navigator.vibrate(pattern);
            } catch (error) {
                console.log('Haptic feedback not available:', error);
            }
        }
    }

    static async pressureSpike() {
        await this.pulse([50, 50, 50]);
    }

    static async choiceSelected() {
        await this.pulse([30]);
    }
}

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { ScamShieldApp, HapticFeedback };
}
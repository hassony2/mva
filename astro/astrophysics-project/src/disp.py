from matplotlib import pyplot as plt


def display_cube(data, label_name, labels, main_title):
    fig = plt.figure()
    ax1 = fig.add_subplot(231)
    ax1.imshow(data[0])
    ax1.set_title('{label_name} {freq}'.format(
        label_name=label_name, freq=labels[0]))
    ax1.axis('off')
    ax2 = fig.add_subplot(232)
    ax2.imshow(data[1])
    ax2.set_title('{label_name} {freq}'.format(
        label_name=label_name, freq=labels[1]))
    ax2.axis('off')
    ax3 = fig.add_subplot(233)
    ax3.imshow(data[2])
    ax3.set_title('{label_name} {freq}'.format(
        label_name=label_name, freq=labels[2]))
    ax3.axis('off')
    ax4 = fig.add_subplot(234)
    ax4.imshow(data[3])
    ax4.set_title('{label_name} {freq}'.format(
        label_name=label_name, freq=labels[3]))
    ax4.axis('off')
    ax5 = fig.add_subplot(235)
    ax5.imshow(data[4])
    ax5.set_title('{label_name} {freq}'.format(
        label_name=label_name, freq=labels[4]))
    ax5.axis('off')
    ax6 = fig.add_subplot(236)
    ax6.imshow(data[5])
    ax6.axis('off')
    ax6.set_title('{label_name} {freq}'.format(
        label_name=label_name, freq=labels[5]))
    fig.suptitle(main_title)
    plt.show()
